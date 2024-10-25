# Copyright (c) 2024 Toivo Henningsson
# SPDX-License-Identifier: BSD-3-Clause

# Track parsing and related functions.
#
# Example:  track = parse_track(8,2," C1, *E1 , G1,, +,, *10")
#
# - Note names and numbers start an interval, last until the next interval is started
# - ,;| take one time step
# - * before a start turns off the trigger. This works for some cases and some kinds of tracks, and leaves the interval without effect for others.
# - + starts a new interval with the last value
# - / sets the the value to NOTHING, can be used as a note-off
#
# parse_track(nsteps::Int, step_size::Int, str::String, ...):
# Max nsteps time steps are expected, the last interval is filled up to that length.
# Each time step adds a wait time of step_size.


struct Interval
	value::Float64
	trigger::Bool
	length::Int
end

const NOTHING = typemin(Int)

@enum TokenType TT_SPECIAL TT_IDENT

struct Token
	tt::TokenType
	str::String
end


mutable struct Track
	set_value::Float64
	value::Float64
	trigger::Bool
	wait_time::Int

	index::Int
	intervals::Vector{Interval}

	Track(intervals::Vector{Interval}) = (e = intervals[1];  new(e.value, e.value, e.trigger, e.length, 1, intervals))
end

wait_time_of(track::Track) = track.index >= length(track.intervals) ? typemax(Int) : track.wait_time

function advance!(track::Track, delta_t::Int)
	track.trigger = false
	track.wait_time -= delta_t
	if track.wait_time == 0 && track.index < length(track.intervals)
		track.index += 1
		interval = track.intervals[track.index]
		track.set_value = track.value = interval.value
		track.trigger = interval.trigger
		track.wait_time = interval.length
	end
	return track.index >= length(track.intervals)
	#return track.wait_time <= 0 && track.index >= length(track.intervals)
end

function pad!(track::Track, len::Int)
	curr_length = sum(interval.length for interval in track.intervals)
	#@show (curr_length, len)
	@assert curr_length <= len

	curr_length == len && return track

	last = track.intervals[end]
	push!(track.intervals, Interval(last.value, false, len - curr_length))

	return track
end


mutable struct State
	timescale::Float64
	tracks::Dict{Any,Track}
	length::Int

	function State(timescale::Real, tracks::Dict{<:Any,Track})
		length = maximum(sum(interval.length for interval in track.intervals) for track in values(tracks))::Int
		tracks = Dict([key => pad!(track, length) for (key, track) in tracks])
		return new(timescale, tracks, length)
	end
end

get_length(s::State) = maximum(sum(interval.length for interval in track.intervals) for track in values(s.tracks))::Int

function lookup_track(s::State, key)
	haskey(s.tracks, key) && return s.tracks[key]
	return s.tracks[:default]
end

function merge!(states::Vector{State})
	#state = states[1]
	state = State(states[1].timescale, Dict([:default => Track(parse_track(0, 1, "*/", 0))]))

	#for s in states
	for i=1:length(states)
		#@show i
		s = states[i]
		append!(state, s)
	end

	return state
end

function Base.append!(dest::State, source::State)
	len = dest.length + source.length
	for (key, track_s) in source.tracks
		if haskey(dest.tracks, key)
			track_d = dest.tracks[key]
		else
			track_d = Track([Interval(NOTHING, false, dest.length)])
			dest.tracks[key] = track_d
		end

		append!(track_d.intervals, track_s.intervals)
	end

#	for track in values(dest.tracks)
#		pad!(track, len)
#	end
	for (key, track) in dest.tracks
		#@show (key, len)
		pad!(track, len)
	end

	dest.length = len
end



const note_names0 = Dict([
	"C" => 0, "C#" => 1, "Db" => 1, "D" => 2, "D#" => 3, "Eb" => 3, "E" => 4, "F" => 5, "F#" => 6,
	"Gb" => 6, "G" => 7, "G#" => 8, "Ab" => 8, "A" => 9, "A#" => 10, "Bb" => 10, "B" => 11
])


const note_names = Dict{String, Int}()
for oct=0:9
	for (name, value) in note_names0
		note_names[string(name, oct)] = value + 12*oct
	end
end



is_special(c::Char) = c in [',', ';','|', '/', '+', '*']

function lex(str::String)
	tokens = Token[]

	i = 1
	ident_start = i
	in_ident = false

	while true
		if in_ident && (i > length(str) || isspace(str[i]) || is_special(str[i]))
			push!(tokens, Token(TT_IDENT, str[ident_start:i-1]))
			in_ident = false
		end

		i > length(str) && break

		c = str[i]

		continue_ident = false
		if is_special(c)
			push!(tokens, Token(TT_SPECIAL, str[i:i]))
		elseif !isspace(c)
			continue_ident = true
			in_ident = true
		end

		if !continue_ident
			ident_start = i+1
		end

		i += 1
	end

	return tokens
end

function parse_ident(str::String, note_offset, note_scale)
	haskey(note_names, str) && return (note_names[str] + note_offset) * note_scale
	return parse(Float64, str)
end


parse_track(nsteps::Int, step_size::Int, str::String, note_offset::Int=0, note_scale::Real=1) = parse_track(nsteps, step_size, lex(str), note_offset, note_scale)


is_value(token::Token) = token.tt == TT_IDENT || (token.tt == TT_SPECIAL && (token.str == "/" || token.str == "+"))


function parse_track(nsteps::Int, step_size::Int, tokens::Vector{Token}, note_offset::Int, note_scale::Real)
	intervals = Interval[]

	value = NOTHING
	last_something_value = NOTHING
	trigger = false
	wait_time = 0
	total_time = 0

	notrig = false
	ignore = true

	i = 1
	while true
		if (i > length(tokens) || is_value(tokens[i])) && !ignore
			if i > length(tokens)
				@assert total_time <= nsteps*step_size
				wait_time += nsteps*step_size - total_time
			end
			push!(intervals, Interval(value, trigger, wait_time))
			trigger = false
			wait_time = 0
		end

		i > length(tokens) && break

		token = tokens[i]

		if is_value(token)
			if token.tt == TT_SPECIAL && token.str == "/"
				value = NOTHING
			elseif token.tt == TT_SPECIAL && token.str == "+"
				# keep last value that was not nothing
				value = last_something_value
			else
				value = parse_ident(token.str, note_offset, note_scale)
			end
			if (value != NOTHING);  last_something_value = value;  end

			trigger = !notrig
			notrig = false
			ignore = false
		elseif token.tt == TT_SPECIAL

			s = token.str
			if s == "," || s == ";" || s == "|" # take one time step
				wait_time  += step_size
				total_time += step_size
				ignore = false
			elseif s == "*"
				notrig = true
			else
				error("Unrecognized special token: '$s'")
			end
		end

		i += 1
	end

	return intervals
end

function next_event!(s::State, max_step::Int = typemax(Int))
	delta_t = minimum(wait_time_of(track) for track in values(state.tracks))
	delta_t = min(delta_t, max_step)
	finished = true
	for track in values(state.tracks)
		finished &= advance!(track, delta_t)
	end
	return finished, delta_t
end
