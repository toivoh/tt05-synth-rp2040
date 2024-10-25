# Copyright (c) 2024 Toivo Henningsson
# SPDX-License-Identifier: BSD-3-Clause

# Functionality for converting parts (tracks combined in a State object) to command strings.


struct SynthState <: Regs
	values::Vector{UInt8}
	changed::BitVector

	SynthState() = new(fill(0xff, 20), falses(20))
end

clear_changed!(s::SynthState) = (s.changed .= false; nothing)

function set_reg8!(s::SynthState, addr::Int, value::Integer)
	#println("set_reg8!(s, $addr, $value)")

	changed = s.changed[begin + addr] || (s.values[begin + addr] != value) || addr < 10  # registers below 10 can change due to sweeps

	s.values[begin + addr] = value
	s.changed[begin + addr] = changed
end

function set_reg16!(s::SynthState, addr::Int, value::Int)
	set_reg8!(s, addr, value & 255)
	set_reg8!(s, addr+1, (value >> 8) & 255)
end

function combine!(s::SynthState)
	if any(s.changed[17:20])
		wf1 = s.values[17] & 3
		wf2 = s.values[18] & 3
		lpf1 = s.values[19] & 1
		lpf2 = s.values[20] & 1

		value = wf1 | (wf2 << 2) | (lpf1 << 6) | (lpf2 << 7)
		#@show (wf1, wf2)

		s.changed[16] = true
		s.values[16] = value
	else
		s.changed[16] = false
	end
end

function to_commands(io::IO, s::SynthState)
	combine!(s)
	#@show s.changed
	skip_next = false
	for i = 15:-1:0
		if s.changed[begin + i]
			set_reg8!(io, i, s.values[begin + i])
		end
	end
end


function play!(io::IO, state::State, s::SynthState=SynthState())
	num_env_phases = 3
	cutoff_sweep_tracks = [lookup_track(state, :cs1), lookup_track(state, :cs2), lookup_track(state, :cs)] # attack / decay /sustain rate
	env_time_tracks = [lookup_track(state, :e1), lookup_track(state, :e2)] # attack / decay time


	tracks = [lookup_track(state, Symbol("t$i")) for i=1:4]


	cutoff_track = lookup_track(state, :c)
	resonance_track = lookup_track(state, :r)
	vol_track = lookup_track(state, :v)
	cutoff_sweep_track = lookup_track(state, :cs)
	cutoff_rand_track = lookup_track(state, :cr)
	retrigger_track = lookup_track(state, :retrig)
	cutoff_delta_track = lookup_track(state, :cd)

	wf1_track = lookup_track(state, :wf1)
	wf2_track = lookup_track(state, :wf2)
	detune_track = lookup_track(state, :detune)


	retrigger_time = typemax(Int)
	#retrigger_time = 128
	retrigger_wait = retrigger_time


	env_phase = num_env_phases
	env_wait = typemax(Int)


	detune = 2

	track0_last_value = NOTHING

	finished = false
	while true
		if retrigger_track.trigger
			retrigger_time = retrigger_track.value == NOTHING ? typemax(Int) : round(Int, retrigger_track.value * state.timescale)
			@assert retrigger_time >= 1
			retrigger_wait = retrigger_time
		end

		osc2_set = false

		if detune_track.trigger && detune_track.value != NOTHING
			detune = Int(detune_track.value)
		end

		for i = 0:min(3, length(state.tracks)-1)
			index = (i == 0 ? 0 : 1)
			track = tracks[begin + i]

			retrigger = (i == 0) && (retrigger_wait == 0)

			soft_retrigger = false
			if i == 0
				soft_retrigger = track.value != track0_last_value
				track0_last_value = track.value
			end

			trigger_cutoff_sweep = false

			wf1_track.trigger && set_reg8!(s, 16, Int(wf1_track.value))
			wf2_track.trigger && set_reg8!(s, 17, Int(wf2_track.value))

			if track.trigger || retrigger || soft_retrigger || cutoff_track.trigger
				value = Int(track.value)

				if !(osc2_set && value == NOTHING)
					oct, p, f = play(s, value == NOTHING ? -20*12 : value, 0, detune, 1 << index)
				end
				if index == 1;  osc2_set = true;  end

				if i == 0
					#@show cutoff_track.trigger
				end
				if i == 0 && (track.trigger || retrigger || cutoff_track.trigger) && value != NOTHING
					if track.trigger;  cutoff_track.value = cutoff_track.set_value
					elseif cutoff_delta_track.value != NOTHING;  cutoff_track.value -= cutoff_delta_track.value
					end

					cutoff = cutoff_track.value
					cutoff_r = cutoff_rand_track.value
					if cutoff_r != NOTHING
						cutoff = cutoff + rand()*(cutoff_r - cutoff)
					end

					resonance = resonance_track.value
					vol = vol_track.value

					cutoff = -cutoff
					cutoff += f/512 + 2
					patch(s, cutoff, vol, resonance)

					trigger_cutoff_sweep = true
				end

				if i > 0 && value != NOTHING # bass / drum / hihat
					if     i == 1;  wf = Int(wf2_track.value);  sweep_off(s, 2)
					elseif i == 2;  wf = 1;  sweep(s, 2, 0, 4)
					elseif i == 3;  wf = 2;  sweep(s, 2, 0, 1)
					else error()
					end
					set_reg8!(s, 17, wf)
				end
			end

			cutoff_sweep_track_trigger = (i == 0 && cutoff_sweep_track.trigger)
			env_trigger = (i == 0 && env_wait == 0)
			if trigger_cutoff_sweep || cutoff_sweep_track_trigger || env_trigger

				if trigger_cutoff_sweep
					env_phase = 1
					while env_phase < num_env_phases && env_time_tracks[env_phase].value == NOTHING
						env_phase += 1
					end
				elseif cutoff_sweep_track_trigger
					env_phase = num_env_phases
				elseif env_trigger
					env_phase += 1
				end

				env_wait = (env_phase == num_env_phases) ? typemax(Int) : round(Int, env_time_tracks[env_phase].value * state.timescale)
				#cutoff_sweep = cutoff_sweep_track.value
				cutoff_sweep = cutoff_sweep_tracks[env_phase].value

				if cutoff_sweep == NOTHING
					sweep_off(s, 4)
					sweep_off(s, 6)
					sweep_off(s, 8)
				else
					sweep_c(s, Int(cutoff_sweep < 0), abs(cutoff_sweep)) # use sign of sweep value to control direction
				end
			end
		end

		to_commands(io, s)

		finished && break

		if retrigger_wait <= 0
			retrigger_wait = retrigger_time
		end
		finished, delta_t = next_event!(state, min(retrigger_wait, env_wait))
		retrigger_wait -= delta_t
		env_wait -= delta_t

		#@show delta_t
		wait!(io, delta_t)

		clear_changed!(s)
	end
end

play!(state::State, s::SynthState=SynthState()) = (io = IOBuffer(); play!(io, state, s); return String(take!(io)))
