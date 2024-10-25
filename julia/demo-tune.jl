# Copyright (c) 2024 Toivo Henningsson
# SPDX-License-Identifier: BSD-3-Clause

# Demo tune for tt05-synth

# The music is also copyright (c) 2024 Toivo Henningsson

module DemoTune


include("tracks.jl")
include("tt05-synth-serial.jl")
include("player.jl")

make_track(n, dt, s) = Track(parse_track(n, dt, s, 0))
make_track(n, dt, note_offset, s) = Track(parse_track(n, dt, s, note_offset))
make_track(n, dt, note_offset, scale, s) = Track(parse_track(n, dt, s, note_offset, scale))

n = 0
dt = 124
dth = dt ÷ 2
timescale = dt


track1 = make_track(n, dt, "*/") # melody
track2 = make_track(n, dt, "*/") # bass
track3 = make_track(n, dt, "*/") # bass drum
track4 = make_track(n, dt, "*/") # hihat

track_default = make_track(0, 1, "*/")

track_c = make_track(n, dt, "3") # cutoff
track_r = make_track(n, dt, "2") # res
track_v = make_track(n, dt, "0") # vol
track_cs = make_track(n, dt, "/") # cutoff_sweep
#track_rs = make_track(n, dt, "/")
#track_vs = make_track(n, dt, "/")
track_cr = make_track(n, dt, "/") # cutoff_rand

track_retrig = make_track(n, dt, "/")
track_cd = make_track(n, dt, "/") # cutoff_delta (applied at retrig)


part_init = State(timescale, Dict([
	:t1 => make_track(n, dt, "/"), :t2 => make_track(n, dt, "*/"), :t3 => make_track(n, dt, "*/"), :t4 => make_track(n, dt, "*/"),
	:c => make_track(n, dt, "3"), # cutoff
	:r => make_track(n, dt, "2"), # res
	:v => make_track(n, dt, "0"), # vol
#	:wf2 => make_track(n, dt, "3"),
	:wf2 => make_track(n, dt, "*3"), # no trigger to work around that we don't want to set wf2 right away, since we start with a drum
	:default => make_track(0, 1, "*/"),
]))




offs1 = -2*12 - 4

cs = 8.5


t1 = t2 = t3 = t4 = tcs = tc = tv = twf1 = tcr = tcd = trt = ""



t3_main = "  C3, /  ,    ,    ;   +, /  ,    ,    ;   +, /  ,    ,    ;   +, /  ,    ,    |   +, /  ,    ,    ;   +, /  ,    ,    ;   +, /  ,    ,    ;   +, /  ,    ,    |"
#t4_main = "   ,,   ,,C8,/,   ,;   ,,   ,,C8,/,   ,;   ,,   ,,C8,/,   ,;   ,,   ,,C8,/,   ,|   ,,   ,,C8,/,   ,;   ,,   ,,C8,/,   ,;   ,,   ,,C8,/,   ,;   ,,   ,,C8,/,   ,|"
t4_main = "   ,,   ,,C8,/,   ,;   ,,   ,,C9,,/   ,;   ,,   ,,C8,/,   ,;   ,,   ,,C9,,/   ,|   ,,   ,,C8,/,   ,;   ,,   ,,C8,/,   ,;   ,,   ,,C8,/,   ,;   ,,   ,,C9,,/   ,|"
t4_main2 = "  ,,   ,,C9,/,   ,;   ,,   ,,C9,,/   ,;   ,,   ,,C9,/,   ,;   ,,   ,,C9,,/   ,|   ,,   ,,C9,/,   ,;   ,,   ,,C9,/,   ,;   ,,   ,,C9,/,   ,;   ,,   ,,C9,,/   ,|"
tcs_main = "$cs,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"
wf1_main = "  1,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"

off_short = "*/,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"; off_main = off_short^2
cutoff_short = "3,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"; cutoff_main = cutoff_short^2
vol_short    = "0,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"; vol_main = vol_short^2


n = 0


# Intro
# =====

intro = State[]

nn = 16
push!(intro, State(timescale, Dict([
	:t1 => make_track(nn,  dt,  offs1, "    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;  A5,    ,  G5,    |"),
	:t2 => make_track(nn,  dt,  offs1, "    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;  A4,    ,  G4,    |"),
	:t3 => make_track(nn,  dt,      0, "  C3,    ,    , /  ;   +,    ,    , /  ;   +,    ,    , /  ;    ,    ,    ,    |"),
	:wf1 => make_track(nn, dt,      0, "   1,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
	:wf2 => make_track(n, dt, "*3"),

	:c => make_track(nn,  dt,  0, cutoff_short), :v => make_track(nn,  dt,  0, vol_short), :cs => make_track(nn, dt, 0, "/"),
])))

#	t1 *= "  E6,    , /  ,    ;  E6,    , /  ,    ;  E6, /  ,    ,    ;  E6, /  ,  F6,    | /  ,    ,  F6,    ; /  ,    ,  F6, /  ;  D6, /  ,  D6, /  ;  D6, /  ,  G5, /  |"
#	t2 *= "  A4,    , /  ,    ;  A4,    , /  ,    ;  A4, /  ,    ,    ;  A4, /  ,  C5,    | /  ,    ,  C5,    ; /  ,    ,  C5, /  ;  G4, /  ,  G4, /  ;  G4, /  ,    ,    |"
#	tcs *= "$cs,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"

#	t1 *= "  E6,    ,    ,    ;  E6,    ,    ,    ;  E6,    ,    ,    ;  E6,    ,  F6,    |    ,    ,  F6,    ;    ,    ,  F6,    ;  D6,    ,  D6,    ;  D6,    ,  G5, /  |"
#	t2 *= "  A4,    ,    ,    ;  A4,    ,    ,    ;  A4,    ,    ,    ;  A4,    ,  C5,    |    ,    ,  C5,    ;    ,    ,  C5,    ;  G4,    ,  G4,    ;  G4,    , /  ,    |"
#	t1 *= "  E6,    ,    , /  ;  E6,    ,    , /  ;  E6,    ,    , /  ;  E6,    ,  F6,    |    , /  ,  F6,    ;    , /  ,  F6,    ;  D6,    ,  D6,    ;  D6,    ,  G5, /  |"

csr = 6 # smaller (shorter) seems to make the playback unreliable, why? Because of the delay between changing top and bottom byte of the associated register?
csp = 8

nn = 32
push!(intro, State(timescale, Dict([
	:t1 => make_track(nn,  dt,  offs1, "  E5,    ,    , /  ;  E5,    ,    , /  ;  E5,    ,    , /  ;  E5, /  ,  F5,    |    , /  ,  F5,    ;    , /  ,  F5, /  ;  D5,    ,  D5, /  ;  D5, /  ,  G5, /  |"), # lowered one octave for the power chords
	:t2 => make_track(nn,  dt,  offs1, "  A4,    ,    , /  ;  A4,    ,    , /  ;  A4,    ,    , /  ;  A4, /  ,  C5,    |    , /  ,  C5,    ;    , /  ,  C5, /  ;  G4,    ,  G4, /  ;  G4, /  , /  ,    |"),
	:t3 => make_track(nn,  dt,      0, "    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
	:t4 => make_track(2nn, dth,     0, "   ,,   ,,   ,,   ,;   ,,   ,,   ,,   ,;   ,,   ,,   ,,   ,;   ,,   ,,   ,,   ,|   ,,   ,,   ,,   ,;   ,,   ,,   ,,   ,;   ,,   ,,   ,,   ,;   ,,   ,,C8, ,   ,|"),
	:cs => make_track(nn,  dt,      0, "$csp,    ,$csr,    ;$csp,    ,$csr,    ;$csp,$csr,    ,    ;$csp,$csr,$csp,    |$csr,    ,$csp,    ;$csr,    ,$csp,$csr;$csp,$csr,$csp,$csr;$csp,$csr, $cs,    |"),
	:c  => make_track(nn,  dt,      0, "   2,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,   3,    |"),
	:v  => make_track(nn,  dt,      0, "   5,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,   0,    |"),
	:wf1 => make_track(nn, dt,      0, "   3,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,   1,    |"),
	:wf2 => make_track(n, dt, "3"),

	:e2 => make_track(nn,  dt,  0,     "0.25,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,   /,    |"), # decay time
	:cs2 => make_track(nn, dt,  0, "-6"), # decay sweep
])))


# A section: melody + bass + drums
# ================================

section_A_chip = State[]

nn = 32
push!(section_A_chip, State(timescale, Dict([
	:t1 => make_track(nn,  dt,  offs1, "  A5,    ,    ,    ;  G5, /  ,  E5,    ; /  ,    ,  A5, /  ;  C6, /  ,  A5, /  |  B5, *A5, *B5,   +; *G5, /  ,  E5,    ; /  ,    ,  A5, /  ;  B5, /  ,  G5, /  |"),
	:t2 => make_track(nn,  dt,  offs1, " /  ,  A4, /  ,  A4; /  ,  A4, /  ,  A4; /  ,    , /  ,  E4; /  ,  C4, /  ,    | /  ,  E4, /  ,  E4; /  ,  A4, /  ,  A4; /  ,    , /  ,  E4; /  ,  E4, /  ,    |"),
	:t3 => make_track(nn,  dt,  0, t3_main), :t4 => make_track(2nn, dth, 0, t4_main), :c => make_track(nn,  dt,  0, cutoff_main), :v => make_track(nn,  dt,  0, vol_main), :cs => make_track(nn,  dt,  0, tcs_main), :wf1 => make_track(nn,  dt,  0, wf1_main), :wf2 => make_track(n, dt, "3"),
])))


nn = 32
push!(section_A_chip, State(timescale, Dict([
	:t1 => make_track(nn,  dt,  offs1, "  A5, *B5,  C6, *A5;  D6, /  ,  F6,    ;  E6, /  ,  B5, /  ;  D6,    ,  E6, /  |  B5,    ,    ,    ;    ,    ,    ,    ;  G5, *B5,*F#5, *B5; *B5, *A5, *C6, *B5|"),
	:t2 => make_track(nn,  dt,  offs1, " /  ,  E4, /  ,  D4; /  ,  F4, /  ,  F4; /  ,    , /  ,  A4; /  ,  A4, /  ,    | /  ,  E5, /  ,  E5; /  ,  B4, /  ,  B4; /  ,  E5, /  ,  B4; /  ,  E5, /  ,  B4|"),
	:cs => make_track(nn,  dt,  0,     "$cs,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |  8.5    ,    ,    ;    ,    ,    ,  10;    ,    ,    ,    ;    ,    ,    ,    |"),
	:t3 => make_track(nn,  dt,  0, t3_main), :t4 => make_track(2nn, dth, 0, t4_main), :c => make_track(nn,  dt,  0, cutoff_main), :v => make_track(nn,  dt,  0, vol_main), :wf1 => make_track(nn,  dt,  0, wf1_main), :wf2 => make_track(n, dt, "3"),
])))

nn = 32
push!(section_A_chip, State(timescale, Dict([
	:t1 => make_track(nn,  dt,  offs1, "  G5, *F5,  A5, *F5;  G5, /  ,  C6,    ;    ,    ,  B5, /  ;  G5,    ,  A5, /  |  C6,    ,    ,    ;  A5, /  ,  G5,    ;    ,    ,  B5,  A5;  C6,  D6,  B5, /  |"),
	:t2 => make_track(nn,  dt,  offs1, " /  ,  C5, /  ,  C5; /  ,  F4, /  ,  F4; /  ,    , /  ,  C5; /  ,  C5, /  ,    | /  ,  G4, /  ,  G4; /  ,  C5, /  ,  C5; /  ,    , /  ,  G4; /  ,  G4, /  ,  D5|"),
	:t3 => make_track(nn,  dt,  0, t3_main), :t4 => make_track(2nn, dth, 0, t4_main), :c => make_track(nn,  dt,  0, cutoff_main), :v => make_track(nn,  dt,  0, vol_main), :cs => make_track(nn,  dt,  0, tcs_main), :wf1 => make_track(nn,  dt,  0, wf1_main), :wf2 => make_track(n, dt, "3"),
])))

for i=1:2
	if i == 1
		tcs =                             " $cs,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |   9,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"
	else
		tcs =                             " $cs,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |10.5,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"
	end
	push!(section_A_chip, State(timescale, Dict([
		:t1 => make_track(nn,  dt,  offs1, "  G5, /  ,  A5, *G5;  B5, /  ,  C6,    ;    ,    ,  A5, /  ;  F5,    ,  C5, /  |  G5,    ,    ,    ; *D5,    , *G5, /  ; *D5,    , *G5, /  ; *D5,    , *G5,    |"),
		:t2 => make_track(nn,  dt,  offs1, " /  ,  D5, /  ,  D5; /  ,  F4, /  ,  F4; /  ,    , /  ,  C5; /  ,  C5, /  ,    | /  ,  D4, /  ,  D4; /  ,  A4, /  ,  G4; /  ,  D4, /  ,  D4; /  ,  A4, /  ,  G4|"),
		#:cs => make_track(nn,  dt,  0,     " $cs,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |   9,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
		:cs => make_track(nn,  dt,  0,     tcs),
		:t3 => make_track(nn,  dt,  0, t3_main), :t4 => make_track(2nn, dth, 0, t4_main), :c => make_track(nn,  dt,  0, cutoff_main), :v => make_track(nn,  dt,  0, vol_main), :wf1 => make_track(nn,  dt,  0, wf1_main), :wf2 => make_track(n, dt, "3"),
	])))
end


# Transition section
# ==================

transition = State[]
nn = 32
push!(transition, State(timescale, Dict([
	:t1 => make_track(nn,  dt,  offs1, "  E5,    , *A5, /  ; *E5,    , *A5, /  ;  B4,    , *E5, /  ; *B4,    , *E5, /  |  C5,    , *F5,    ; *C5,    , *F5,    ;  D5,    ,*G5 ,    ; *D5,    , *G5, /  |"),
	:t2 => make_track(nn,  dt,  offs1, " /  ,  B4, /  ,  A4; /  ,  E4, /  ,  E4; /  , F#4, /  ,  E4; /  ,  B3, /  ,  B3| /  ,  G4, /  ,  F4; /  ,  C4, /  ,  C4; /  ,  A4, /  ,  G4; /  ,  D4, /  ,    |"),
	:c  => make_track(nn,  dt,  0,     "   1,    ,    ,    ;    ,    ,    ,    ;1.5 ,    ,    ,    ;    ,    ,    ,    |2   ,    ,    ,    ;    ,    ,    ,    ;2.5 ,    ,    ,    ;    ,    ,    ,    |"),
	:cs => make_track(nn,  dt,  0,     "   9,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |   9,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
	:v => make_track(nn,  dt,  0, vol_main), :wf1 => make_track(nn,  dt,  0, wf1_main), :wf2 => make_track(n, dt, "3"),
])))


# S&H cutoff section
# ==================

SnH0 = State[]

for i = 1:2
	if i == 1
		tc_part = "   4,,    ,;    ,,    ,;    ,,    ,;    ,,    ,|   5,,     ;    ,,    ,;    ,,    ,;    ,,    ,|   6,,    ,;    ,,    ,;    ,,    ,;    ,,    ,|   7,,    ,;    ,,    ,;    ,,    ,; *  ,,    ,|  "
	else
		tc_part = "   8,,    ,;    ,,    ,;    ,,    ,;    ,,    ,|   7,,     ;    ,,    ,;    ,,    ,;    ,,    ,|   6,,    ,;    ,,    ,;    ,,    ,;    ,,    ,|   5,,    ,;    ,,    ,;    ,,    ,; *  ,,    ,|  "
	end

	nn = 64
	push!(SnH0, State(timescale, Dict([
		:t1 => make_track(nn,  dt,  offs1, "  E5,,    ,;    ,,    ,;    ,,    ,; *C5,,  E5,|  E5,,     ;    ,,    ,; *E5,,*F#5,; *G5,,*F#5,|  C5,,    ,;    ,,    ,;    ,,    ,; *D5,, *C5,|  D5,,    ,;    ,,    ,;    ,,    ,; *E5,, *D5,|  "),
		:t2 => make_track(nn,  dt,  offs1, "  A4,,    ,;    ,,    ,;  A4,, *B4,; *G4,, *B4,|  B4,,    ,;    ,,    ,;    ,,    ,; *D5,, *B4,|  F4,,    ,;    ,,    ,; *F4,, *G4,; *A4,, *G4,|  G4,,    ,;    ,,    ,; *G4,, *A4,; *B4,, *A4,|  "),
		:cs => make_track(nn,  dt,  0,     " /  ,,    ,;    ,,    ,;    ,,    ,;    ,,    ,|    ,,     ;    ,,    ,;    ,,    ,;    ,,    ,|    ,,    ,;    ,,    ,;    ,,    ,;    ,,    ,|    ,,    ,;    ,,    ,;    ,,    ,; *  ,,    ,|  "),
		:c  => make_track(nn,  dt,  0,     tc_part),
		:cr => make_track(nn,  dt,  0,     "   0,,    ,;    ,,    ,;    ,,    ,;    ,,    ,|    ,,     ;    ,,    ,;    ,,    ,;    ,,    ,|    ,,    ,;    ,,    ,;    ,,    ,;    ,,    ,|    ,,    ,;    ,,    ,;    ,,    ,; *  ,,    ,|  "),
		:cd => make_track(nn,  dt,  0,     "   1,,    ,;    ,,    ,;    ,,    ,;    ,,    ,|    ,,     ;    ,,    ,;    ,,    ,;    ,,    ,|    ,,    ,;    ,,    ,;    ,,    ,;    ,,    ,|    ,,    ,;    ,,    ,;    ,,    ,; *  ,,    ,|  "),
		:retrig => make_track(nn,  dt,  0,     "   2,,    ,;    ,,    ,;    ,,    ,;    ,,    ,|    ,,     ;    ,,    ,;    ,,    ,;    ,,    ,|    ,,    ,;    ,,    ,;    ,,    ,;    ,,    ,|    ,,    ,;    ,,    ,;    ,,    ,; *  ,,    ,|  "),
		:wf1 => make_track(nn,  dt,  0,     "3"), :wf2 => make_track(n, dt, "3"),
		:v => make_track(nn,  dt,  0, vol_main),
	])))
end


# A section: brass version
# ========================

section_A_brass = State[]

css = 10
csr = 7
#dt2 = 2dt
dt2 = dt

nn = 32
push!(section_A_brass, State(timescale, Dict([
#	:t1 => make_track(nn,  dt2,  offs1, "  A5,    ,    ,    ;  G5, /  ,  E5,    ; /  ,    ,  A5, /  ;  C6, /  ,  A5, /  |  B5, *A5, *B5,   +; *G5, /  ,  E5,    ; /  ,    ,  A5, /  ;  B5, /  ,  G5, /  |"),
#	:t2 => make_track(nn,  dt2,  offs1, "  A5,    ,    ,    ;  G5,    ,  E5,    ;    ,    ,  A5,    ;  C6,    ,  A5,    |  B5,  A5,  B5,    ;  G5,    ,  E5,    ;    ,    ,  A5,    ;  B5,    ,  G5,    |"),
#	:cs => make_track(nn,  dt2,  0,     "$css,    ,    ,    ;$css,$csr,$css,    ;$csr,    ,$css,$csr;$css,$csr,$css,$csr|$css,    ,    ,    ;    ,$csr,$css,    ;$csr,    ,$css,$csr;$css,$csr,$css,$csr|"),
	#:t1 => make_track(nn,  dt2,  offs1, "  A5,    ,    ,    ;  G5,    ,  E5,    ;    ,    ,  A5,    ;  C6,    ,  A5,    |  B5, *A5, *B5,    ;  G5,    ,  E5,    ;    ,    ,  A5,    ;  B5,    ,  G5,    |"),
	#:t2 => make_track(nn,  dt2,  offs1, "  A5,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |  E5,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
	:cs => make_track(nn,  dt2,  0,     "$css,    ,    ,    ;$css,$csr,$css,    ;$csr,    ,$css,$csr;$css,$csr,$css,$csr|$css,    ,    ,    ;    ,$csr,$css,    ;    ,$csr,$css,$csr;$css,$csr,$css,$csr|"),
	:t1 => make_track(nn,  dt2,  offs1, "  A5,    ,    ,    ;  G5, /  ,  E5,    ; /  ,    ,  A5,    ;  C6, /  ,  A5, /  |  B5, *A5, *B5,    ;  G5, /  ,  E6,    ;    ,    ,  A5, /  ;  B5, /  ,  G5, /  |"),
	:t2 => make_track(nn,  dt2,  offs1, "  A5,    ,    ,    ;  G5,    ,  E5,    ;    ,    ,  A5,    ;    ,    ,    ,    |  E5,    ,    ,    ;    ,    ,    ,    ;    ,    ,  A5,    ;  B5,    ,  G5,    |"),
	##t4_main:                           "   ,,   ,,C8,/,   ,;   ,,   ,,C9,,/   ,;   ,,   ,,C8,/,   ,;   ,,   ,,C9,,/   ,|   ,,   ,,C8,/,   ,;   ,,   ,,C8,/,   ,;   ,,   ,,C8,/,   ,;   ,,   ,,C9,,/   ,|"
	#:t2 => make_track(nn,  dt2,  offs1, "  A5,    ,    , +  ;  G5,    ,  E5, +  ;    ,    ,  A5, +  ;    ,    ,    , +  |  E5,    ,    , +  ;    ,    ,    , +  ;    ,    ,  A5, +  ;  B5,    ,  G5, +  |"),
	:r => make_track(nn,  dt2,  0, "0.5"),
	:c => make_track(nn,  dt2,  0, "0"),
	:e1 => make_track(nn,  dt2,  0, "0.5"), # attack time
	:cs1 => make_track(nn,  dt2,  0, "-5"), # attack sweep
	:e2 => make_track(nn,  dt2,  0, "1"), # decay time
	:cs2 => make_track(nn,  dt2,  0, "7.5"), # decay sweep
	#:cs => make_track(nn,  dt2,  0, "11"), # sustain sweep
	:v => make_track(nn, dt2, 0, "0"), :wf1 => make_track(nn, dt2, 0, "3"), :retrig => make_track(nn, dt2, 0, "/"), :detune => make_track(nn, dt2, 0, "3"), :wf2 => make_track(n, dt, "3"),
	#:t4 => make_track(2nn, dth, 0, t4_main2)
])))

nn = 32
push!(section_A_brass, State(timescale, Dict([
#	:t1 => make_track(nn,  dt2,  offs1, "  A5, *B5,  C6, *A5;  D6, /  ,  F6,    ;  E6, /  ,  B5, /  ;  D6,    ,  E6, /  |  B5,    ,    ,    ;    ,    ,    ,    ;  G5, *B5,*F#5, *B5; *B5, *A5, *C6, *B5|"),
#	:t2 => make_track(nn,  dt2,  offs1, "  A5,  B5,  C6,  A5;  D6,    ,  F6,    ;  E6,    ,  B5,    ;  D6,    ,  E6,    |  B5,    ,    ,    ;    ,    ,    ,    ;  G5,  B5, F#5,  B5;  B5,  A5,  C6,  B5|"),
#	:t2 => make_track(nn,  dt2,  offs1, "  A5,  B5,  C6,  A5;  D6,    ,  F6,    ;  E6,    ,  B5,    ;  D6,    ,  E6,    |  B5,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,  C6,  B5|"),
#	:t1 => make_track(nn,  dt2,  offs1, "  A5, *B5,  C6, *A5;  D6,    ,  F6,    ;  E6,    ,  B5,    ;  D6,    ,  E6,    |  B5,    ,    ,    ;    ,    ,    ,    ;  G5,  B5, F#5,  B5;  B5,  A5,  C6,  B5|"),
#	:t2 => make_track(nn,  dt2,  offs1, "  E5,    ,    ,    ;  D6,    ,    ,    ;  E6,    ,    ,    ;    ,    ,    ,    |  B5,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,  C6,  B5|"),
#	:cs => make_track(nn,  dt2,  0,     "$css,    ,    ,    ;$css,$csr,$css,    ;$css,$csr,$css,$csr;$css,$csr,$css,$csr|$css,    ,    ,    ;    ,    ,    ,    ;$css,    ,    ,    ;    ,    ,    ,    |"),
	:cs => make_track(nn,  dt2,  0,     "$css,    ,    ,    ;$css,$csr,$css,$csr;$css,$csr,$css,$csr;$css,    ,$css,$csr|$css,    ,    ,    ;    ,    ,    ,$csr;$css,    ,    ,    ;    ,    ,    ,    |"),
	:t1 => make_track(nn,  dt2,  offs1, "  A5, *B5, *C6, *A5;  D6, /  ,  F6, /  ;  E6, /  ,  B5, /  ;  D6,    ,  E6, /  |  B5,    ,    ,    ;    ,    ,    ,    ;  G5,  B5, F#5,  B5;  A5,  B5,  C6,  B5|"),
	:t2 => make_track(nn,  dt2,  offs1, "  D5,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |  E5,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
	:r => make_track(nn,  dt2,  0, "0.5"),
	:c => make_track(nn,  dt2,  0, "0"),
	:e1 => make_track(nn,  dt2,  0, "0.5"), # attack time
	:cs1 => make_track(nn,  dt2,  0, "-5"), # attack sweep
	:e2 => make_track(nn,  dt2,  0, "1"), # decay time
	:cs2 => make_track(nn,  dt2,  0, "7.5"), # decay sweep
	#:cs => make_track(nn,  dt2,  0, "11"), # sustain sweep
	:v => make_track(nn, dt2, 0, "0"), :wf1 => make_track(nn, dt2, 0, "3"), :retrig => make_track(nn, dt2, 0, "/"), :detune => make_track(nn, dt2, 0, "3"), :wf2 => make_track(n, dt, "3"),
])))

nn = 32
push!(section_A_brass, State(timescale, Dict([
#	:t1 => make_track(nn,  dt2,  offs1, "  G5, *F5,  A5, *F5;  G5, /  ,  C6,    ;    ,    ,  B5, /  ;  G5,    ,  A5, /  |  C6,    ,    ,    ;  A5, /  ,  G5,    ;    ,    ,  B5,  A5;  C6,  D6,  B5, /  |"),
#	:t2 => make_track(nn,  dt2,  offs1, "  G5,  F5,  A5,  F5;  G5,    ,  C6,    ;    ,    ,  B5,    ;  G5,    ,  A5,    |  C6,    ,    ,    ;  A5,    ,  G5,    ;    ,    ,  B5,  A5;  C6,  D6,  B5,    |"),
#	:t1 => make_track(nn,  dt2,  offs1, "  G5, *F5,  A5, *F5;  G5,    ,  C6,    ;    ,    ,  B5,    ;  G5,    ,  A5,    |  C6,    ,    ,    ;  A5,    ,  G5,    ;    ,    ,  B5,  A5;  C6,  D6,  B5,    |"),
#	:t2 => make_track(nn,  dt2,  offs1, "  C5,    ,    ,    ;    ,    ,    ,    ;    ,    ,  E5,    ;    ,    ,    ,    |  C5,    ,    ,    ;    ,    ,    ,    ;    ,    ,  E5,    ;    ,    ,    ,    |"),
#	:cs => make_track(nn,  dt2,  0,     "$css,    ,    ,    ;$css,$csr,$css,    ;    ,    ,$css,$csr;$css,    ,$css,$csr|$css,    ,    ,    ;$css,$csr,$css,    ;    ,    ,$css,    ;    ,    ,    ,$csr|"),
	:cs => make_track(nn,  dt2,  0,     "$css,    ,    ,    ;$css,$csr,$css,    ;    ,    ,$css,$csr;$css,$csr,$css,$csr|$css,    ,    ,    ;$css,$csr,$css,    ;    ,    ,$css,    ;    ,    ,    ,$csr|"),
	:t1 => make_track(nn,  dt2,  offs1, "  G5, *F5, *A5, *F5;  G5, /  ,  C6,    ;    ,    ,  B5, /  ;  G5, /  ,  A5, /  |  C6,    ,    ,    ;  A5, /  ,  G5,    ;    ,    ,  B5,  A5;  C6,  D6,  B5, /  |"),
	:t2 => make_track(nn,  dt2,  offs1, "  D5,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |  C5,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
	:r => make_track(nn,  dt2,  0, "0.5"),
	:c => make_track(nn,  dt2,  0, "0"),
	:e1 => make_track(nn,  dt2,  0, "0.5"), # attack time
	:cs1 => make_track(nn,  dt2,  0, "-5"), # attack sweep
	:e2 => make_track(nn,  dt2,  0, "1"), # decay time
	:cs2 => make_track(nn,  dt2,  0, "7.5"), # decay sweep
	#:cs => make_track(nn,  dt2,  0, "11"), # sustain sweep
	:v => make_track(nn, dt2, 0, "0"), :wf1 => make_track(nn, dt2, 0, "3"), :retrig => make_track(nn, dt2, 0, "/"), :detune => make_track(nn, dt2, 0, "3"), :wf2 => make_track(n, dt, "3"),
])))

nn = 32
push!(section_A_brass, State(timescale, Dict([
#	:t1 => make_track(nn,  dt2,  offs1, "  G5, /  ,  A5, *G5;  B5, /  ,  C6,    ;    ,    ,  A5, /  ;  F5,    ,  C5, /  |  G5,    ,    ,    ; *D5,    , *G5, /  ; *D5,    , *G5, /  ; *D5,    , *G5,    |"),
#	:t2 => make_track(nn,  dt2,  offs1, "  G5,    ,  A5,  G5;  B5,    ,  C6,    ;    ,    ,  A5,    ;  F5,    ,  C5,    |  G5,    ,    ,    ;  D5,    ,  G5,    ;  D5,    ,  G5,    ;  D5,    ,  G5,    |"),
#	:t2 => make_track(nn,  dt2,  offs1, "  G5,    ,  A5,  G5;  B5,    ,  C6,    ;    ,    ,  A5,    ;  F5,    ,  C5,    |  G5,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
#	:t1 => make_track(nn,  dt2,  offs1, "  G5,    ,  A5, *G5;  B5,    ,  C6,    ;    ,    ,  A5,    ;  F5,    ,  C5,    |  G5,    ,    ,    ;  D5,    ,  G5,    ;  D5,    ,  G5,    ;  D5,    ,  G5,    |"),
#	:t2 => make_track(nn,  dt2,  offs1, "  E5,    ,    ,    ;    ,    ,    ,    ;    ,    ,  F5,    ;    ,    ,    ,    |  G5,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
#	:cs => make_track(nn,  dt2,  0,     "$css,$csr,    ,    ;$css,$csr,$css,    ;$csr,    ,$css,$csr;$css,$csr,$css,$csr|$css,    ,    ,    ;    ,$csr,$css,    ;$csr,    ,$css,$csr;$css,$csr,$css,$csr|"),
	:cs => make_track(nn,  dt2,  0,     "$css,$csr,    ,    ;$css,$csr,$css,    ;    ,    ,$css,$csr;$css,    ,$css,$csr|$css,    ,    ,$csr;    ,    ,$css,$csr;$csr,    ,$css,$csr;$css,    ,$css,$csr|"),
	:t1 => make_track(nn,  dt2,  offs1, "  G5,    ,  A5, *G5;  B5, /  ,  C6,    ;    ,    ,  A5, /  ;  F5,    ,  C5, /  |  G5,    ,    ,    ;  D5,    ,  G5, /  ;  D5,    ,  G5, /  ;  D5,    ,  G5, /  |"),
	:t2 => make_track(nn,  dt2,  offs1, "  F5,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |  G5,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
	:r => make_track(nn,  dt2,  0, "0.5"),
	:c => make_track(nn,  dt2,  0, "0"),
	:e1 => make_track(nn,  dt2,  0, "0.5"), # attack time
	:cs1 => make_track(nn,  dt2,  0, "-5"), # attack sweep
	:e2 => make_track(nn,  dt2,  0, "1"), # decay time
	:cs2 => make_track(nn,  dt2,  0, "7.5"), # decay sweep
	#:cs => make_track(nn,  dt2,  0, "11"), # sustain sweep
	:v => make_track(nn, dt2, 0, "0"), :wf1 => make_track(nn, dt2, 0, "3"), :retrig => make_track(nn, dt2, 0, "/"), :detune => make_track(nn, dt2, 0, "3"), :wf2 => make_track(n, dt, "3"),
])))


# B section
# =========

section_B = State[]

cb0 = 0.5 - 1.25
offs2 = offs1 + 12
css = "/"
csr = 4.5

nn = 32
cb = cb0 - 0.5
push!(section_B, State(timescale, Dict([
	#:t1 => make_track(nn,  dt,  offs2, "    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
	#:t1 => make_track(nn,  dt,  offs2, "  A5,    ,    ,    ;    ,    ,  G5, /  ;  A5,    ,    ,    ;    ,    ,  A5,  G5|  A5,    ,    ,    ;  A5, /  ,  B5, /  ; F#5,    ,    ,    ;    ,    ,    ,    |"),
	:t1 => make_track(nn,  dt,  offs2, "  A5,    ,    ,    ;    ,    ,  G5,    ;  A5,    ,    ,    ;    ,    ,  A5,  G5|  A5,    ,    ,    ;  A5,    ,  B5,    ; F#5,    ,    ,    ;    ,    ,    ,    |"),
	:t2 => make_track(nn,  dt,  offs2, "  A4,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,    ,    ;  B4,    ,    ,    ;  E5,    , F#5, /  |"),
	:cs => make_track(nn,  dt,      0, "$css,    ,    ,    ;    ,    ,$css,$csr;$css,    ,    ,    ;    ,    ,$css,$css|$css,    ,    ,    ;$css,$csr,$css,$csr;$css,    ,    ,    ;    ,    ,    ,    |"),
	:e1 => make_track(nn,  dt,  0, "0.25"), # attack time
	:cs1 => make_track(nn,  dt,  0, "-5"), # attack sweep
	:e2 => make_track(nn,  dt,  0, "0"), # decay time
	:cs2 => make_track(nn,  dt,  0, "/"), # decay sweep
	:r => make_track(nn,  dt,  0, "0"),
	:c => make_track(nn,  dt,  0, "$cb"), :v => make_track(nn,  dt,  0, vol_main), :wf1 => make_track(nn,  dt,  0, "1"), :wf2 => make_track(nn,  dt,  0, "1"),
])))

nn = 32
cb = cb0 - 1
push!(section_B, State(timescale, Dict([
	#:t1 => make_track(nn,  dt,  offs2, "    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
	#:t1 => make_track(nn,  dt,  offs2, "  G5,    ,    ,    ;  G5, /  ,  G5, F#5;  G5,    ,    ,  A5;    , /  ,  G5, /  | F#5,    ,    ,    ; /  ,    ,  E5,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
	:t1 => make_track(nn,  dt,  offs2, "  G5,    ,    ,    ;  G5,    ,  G5, F#5;  G5,    ,    ,  A5;    ,    ,  G5,    | F#5,    ,    ,    ;    ,    ,  E5,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
	:t2 => make_track(nn,  dt,  offs2, "  E4,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,  B4,    ;    , /  ,  B4,    ;  G4,    ,  B4, /  |"),
	:cs => make_track(nn,  dt,      0, "$css,    ,    ,    ;$css,$csr,$css,$css;$css,    ,    ,$css;    ,$csr,$css,$csr|$css,    ,    ,    ;$csr,    ,$css,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
	:e1 => make_track(nn,  dt,  0, "0.25"), # attack time
	:cs1 => make_track(nn,  dt,  0, "-5"), # attack sweep
	:e2 => make_track(nn,  dt,  0, "0"), # decay time
	:cs2 => make_track(nn,  dt,  0, "/"), # decay sweep
	:r => make_track(nn,  dt,  0, "0"),
	:c => make_track(nn,  dt,  0, "$cb"), :v => make_track(nn,  dt,  0, vol_main), :wf1 => make_track(nn,  dt,  0, "1"), :wf2 => make_track(nn,  dt,  0, "1"),
])))

nn = 32
cb = cb0
push!(section_B, State(timescale, Dict([
	#:t1 => make_track(nn,  dt,  offs2, "    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
	#:t1 => make_track(nn,  dt,  offs2, "  G5,    ,    ,    ;    ,    , F#5, /  ;  G5,    ,    ,    ;    ,    ,  G5, F#5|  G5,    ,    ,    ; F#5,    ,  E5, /  ;  B5,    ,    ,    ;  C6,    ,  A5, /  |"),
	:t1 => make_track(nn,  dt,  offs2, "  G5,    ,    ,    ;    ,    , F#5,    ;  G5,    ,    ,    ;    ,    ,  G5, F#5|  G5,    ,    ,    ; F#5,    ,  E5,    ;  B5,    ,    ,    ; *C6,    , *A5,    |"),
	:t2 => make_track(nn,  dt,  offs2, "  G4,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,    ,    ;  E4,    ,    ,    ;    ,    ,    ,    |"),
	:cs => make_track(nn,  dt,      0, "$css,    ,    ,    ;    ,    ,$css,$csr;$css,    ,    ,    ;    ,    ,$css,$css|$css,    ,    ,    ;$css,    ,$css,$csr;$css,    ,    ,    ;$css,    ,$css,$csr|"),
	:c => make_track(nn,  dt,  0, "$cb"), :v => make_track(nn,  dt,  0, vol_main), :wf1 => make_track(nn,  dt,  0, "1"), :wf2 => make_track(nn,  dt,  0, "1"),
])))

nn = 32
cb = cb0 + 0.5
push!(section_B, State(timescale, Dict([
	#:t1 => make_track(nn,  dt,  offs2, "    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
	#:t1 => make_track(nn,  dt,  offs2, "  G5,    ,    ,    ;  G5, /  , F#5, /  ;  G5,    ,    ,  A5;    , /  ,  G5, /  | F#5,    ,    ,    ; /  ,    ,  E5,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
	:t1 => make_track(nn,  dt,  offs2, "  G5,    ,    ,    ;  G5,    , F#5,    ;  G5,    ,    ,  A5;    ,    ,  G5,    | F#5,    ,    ,    ;    ,    ,  E5,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
	:t2 => make_track(nn,  dt,  offs2, "  G4,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,  A4,    ;    , /  ,  A4,    ;  E4,    ,  A4, /  |"),
	:cs => make_track(nn,  dt,      0, "$css,    ,    ,    ;$css,$csr,$css,$csr;$css,    ,    ,$css;    ,$csr,$css,$csr|$css,    ,    ,    ;$csr,    ,$css,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
	:e1 => make_track(nn,  dt,      0, "0.25,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |/"),
	:e2 => make_track(nn,  dt,      0, "0   ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |/"),
	:c => make_track(nn,  dt,  0, "$cb"), :v => make_track(nn,  dt,  0, vol_main), :wf1 => make_track(nn,  dt,  0, "1"), :wf2 => make_track(nn,  dt,  0, "1"),
])))


# A section: Cutoff modulation on static chords
# =============================================

section_A_cutoff = State[]

off = "C5"
offs3_0 = -note_names["E5"]
scale = 6/12
#offs3_0 += round(Int, 1/scale)

nn = 32
offs3 = offs3_0 + round(Int, 0/scale)
push!(section_A_cutoff, State(timescale, Dict([
	:c => make_track(nn,  dt,  offs3, scale, "  A5,    ,    ,    ;  G5,$off,  E5,    ;$off,    ,  A5,$off;  C6,$off,  A5,$off|  B5,  A5,  B5,   +;  G5,$off,  E5,    ;$off,    ,  A5,$off;  B5,$off,  G5,$off|"),
	#:t1 => make_track(nn,  dt,  offs1, "  E5,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
	#:t2 => make_track(nn,  dt,  offs1, "  A4,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
	#:t2 => make_track(nn,  dt,  offs1, "  A4,  B4,  A4,  B4;  A4,  B4,  A4,  B4;  A4,  B4,  A4,  B4;  A4,  B4,  A4,  B4|  A4,  B4,  A4,  B4;  A4,  B4,  A4,  B4;  A4,  B4,  A4,  B4;  A4,  B4,  A4,  B4|"),
	#:t2 => make_track(nn,  dt,  offs1, "  A4,    ,  B4,    ;  A4,    ,  B4,    ;  A4,    ,  B4,    ;  A4,    ,  B4,    |  A4,    ,  B4,    ;  A4,    ,  B4,    ;  A4,    ,  B4,    ;  A4,    ,  B4,    |"),
	:t1 => make_track(nn,  dt,  offs1, "  E5,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |  E5,    ,    ,    ;    ,    ,    ,    ;    ,    ,  C5,    ;  E5,    ,  C5,    |"),
	:t2 => make_track(nn,  dt,  offs1, "  A4,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |  A4,    ,  B4,    ;  A4,    ,  B4,    ;  A4,    ,  G4,    ;  A4,    ,  G4,    |"),
	:v => make_track(nn,  dt,  0, vol_main), :cs => make_track(nn,  dt,  0, "/"), :wf1 => make_track(nn,  dt,  0, "3"),  :wf2 => make_track(nn,  dt,  0, "3"),
])))

nn = 32
offs3 = offs3_0 + round(Int, -1/scale)
push!(section_A_cutoff, State(timescale, Dict([
#	:c => make_track(nn,  dt,  offs3, scale, "  A5,  B5,  C6,  A5;  D6,$off,  F6,    ;  E6,$off,  B5,$off;  D6,    ,  E6,$off|  B5,    ,    ,    ;    ,    ,    ,    ;  G5,  B5, F#5,  B5;  B5,  A5,  C6,  B5|"),
	:c => make_track(nn,  dt,  offs3, scale, "  A5,  B5,  C6,  A5;  D6,$off,  F6,    ;  E6,$off,  B5,$off;  D6,    ,  E6,$off|  B5,    ,    ,    ;  E5,    ,  B5,$off;  G5,  B5, F#5,  B5;  B5,  A5,  C6,  B5|"),
	#:t1 => make_track(nn,  dt,  offs1, "  B4,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
	#:t2 => make_track(nn,  dt,  offs1, "  E4,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
	:t1 => make_track(nn,  dt,  offs1, "  B4,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |  B4,    ,    ,    ;    ,    ,    ,    ;    ,    ,  G4,    ;  B4,    ,  G4,    |"),
	:t2 => make_track(nn,  dt,  offs1, "  E4,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |  E4,    , F#4,    ;  E4,    , F#4,    ;  E4,    ,  D4,    ;  E4,    ,  D4,    |"),
	:v => make_track(nn,  dt,  0, vol_main), :cs => make_track(nn,  dt,  0, "/"), :wf1 => make_track(nn,  dt,  0, "3"),  :wf2 => make_track(nn,  dt,  0, "3"),
])))

nn = 32
offs3 = offs3_0 + round(Int, 1/scale)
push!(section_A_cutoff, State(timescale, Dict([
	:c => make_track(nn,  dt,  offs3, scale, "  G5,  F5,  A5,  F5;  G5,$off,  C6,    ;    ,    ,  B5,$off;  G5,    ,  A5,$off|  C6,    ,    ,    ;  A5,$off,  G5,    ;    ,    ,  B5,  A5;  C6,  D6,  B5,$off|"),
	#:t1 => make_track(nn,  dt,  offs1, "  C5,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
	#:t2 => make_track(nn,  dt,  offs1, "  F4,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
	:t1 => make_track(nn,  dt,  offs1, "  C5,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |  C5,    ,    ,    ;    ,    ,    ,    ;    ,    ,  A4,    ;  C5,    ,  A4,    |"),
	:t2 => make_track(nn,  dt,  offs1, "  F4,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |  F4,    ,  G4,    ;  F4,    ,  G4,    ;  F4,    ,  E4,    ;  F4,    ,  E4,    |"),
	:v => make_track(nn,  dt,  0, vol_main), :cs => make_track(nn,  dt,  0, "/"), :wf1 => make_track(nn,  dt,  0, "3"),  :wf2 => make_track(nn,  dt,  0, "3"),
])))

nn = 32
offs3 = offs3_0 + round(Int, 0/scale)
push!(section_A_cutoff, State(timescale, Dict([
	:c => make_track(nn,  dt,  offs3, scale, "  G5,$off,  A5,  G5;  B5,$off,  C6,    ;    ,    ,  A5,$off;  F5,    ,  C5,$off|  G5,    ,    ,    ;  D5,    ,  G5,$off;  D5,    ,  G5,$off;  D5,    ,  G5,    |"),
#	:t1 => make_track(nn,  dt,  offs1, "  D5,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
#	:t2 => make_track(nn,  dt,  offs1, "  G4,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |"),
	:t1 => make_track(nn,  dt,  offs1, "  D5,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |  D5,    ,    ,    ;    ,    ,    ,    ;    ,    ,  B4,    ;  D5,    ,  B4, /  |"),
	:t2 => make_track(nn,  dt,  offs1, "  G4,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    ;    ,    ,    ,    |  G4,    ,  A4,    ;  G4,    ,  A4,    ;  G4,    , F#4,    ;  G4,    , F#4, /  |"),
	:v => make_track(nn,  dt,  0, vol_main), :cs => make_track(nn,  dt,  0, "/"), :wf1 => make_track(nn,  dt,  0, "3"),  :wf2 => make_track(nn,  dt,  0, "3"),
])))


# Resolution: Cutoff echo
# =======================
resolution = State[]

nn = 32
push!(resolution, State(timescale, Dict([
	:c => make_track(nn,  dt,  offs3, scale, "3"),
	:t1 => make_track(nn,  dt,  offs1, "A5,,,; ,,,; ,,,; ,,,| ,,,; ,,,; ,,,; ,,,|*A5"),
	#:t1 => make_track(nn,  dt,  offs1, "E5,,,; ,,,; ,,,; ,,,| ,,,; ,,,; ,,,; ,,,|*E5"),
	#:t2 => make_track(nn,  dt,  offs1, "A4,"),
	#:t2 => make_track(nn,  dt,  offs1, "/,A4,/,A4;/,A4,/,A4;/,A4,/,A4;/,A4,/,A4|/,A4,/,A4;/,A4,/,A4;/,A4,/,A4;/,A4,/,A4|/"),
	:t2 => make_track(nn,  dt,  offs1, "/,E4,/,E4;/,E4,/,E4;/,E4,/,E4;/,E4,/,E4|/,E4,/,E4;/,E4,/,E4;/,E4,/,E4;/,E4,/,E4|/"),
	:cs => make_track(nn,  dt,  0, "8.5"),
	:retrig => make_track(nn,  dt,  0, "2"),
	:cd => make_track(nn,  dt,  0, "0.45"),
	:v => make_track(nn,  dt,  0, "0"), :wf1 => make_track(nn,  dt,  0, "1"), :wf2 => make_track(nn,  dt,  0, "3"),
])))



parts = [part_init]


# Main song
# =========

#append!(parts, intro[[2]])
append!(parts, intro)
#append!(parts, section_A_chip[[1]])
append!(parts, section_A_chip[1:4])
#append!(parts, transition)
#append!(parts, section_A_cutoff[[1,2,3]])
#append!(parts, section_A_cutoff)
append!(parts, section_A_brass)

#append!(parts, intro[[2]])
push!(parts, part_init)
append!(parts, section_B)

push!(parts, part_init)
append!(parts, section_A_chip[1:4])
#append!(parts, section_A_chip[[1,2,3,5]])
#append!(parts, section_A_chip[[5]])
#append!(parts, resolution)
append!(parts, transition)

append!(parts, section_A_cutoff)
push!(parts, part_init)
append!(parts, intro[[2]])
append!(parts, section_A_chip[[1,2,3,5]])
#append!(parts, section_A_chip[[5]])
append!(parts, resolution)


# Trying different parts
# ======================

#append!(parts, intro[[2]])
#append!(parts, section_A_chip[[1]])

#=
append!(parts, section_A_chip[[4]])
#append!(parts, section_A_brass)
append!(parts, section_A_brass[[1]])
#append!(parts, section_B[[1]])
=#

#=
append!(parts, section_A_brass)
append!(parts, transition)
push!(parts, part_init)
append!(parts, section_A_chip)
#append!(parts, resolution)
=#
#append!(parts, resolution)


#println("merge!")
state = merge!(parts)


s = SynthState()

io = IOBuffer()
sweep_off(io); play(io,0,-20); play_patch(io,0,4,1;resonance=0,mask=0); wait!(io,dt);
init_str = String(take!(io));
#println("serial!(", repr(init_str), ")\n")

str = play!(state, s)
#println("serial!(", repr(str), ")\n")
println("serial!(\"", string(init_str, " ", str), "\")\n")

# sweep_off(); play_patch(0, 4, 6; vol=2) # clearly audible sound
sweep_off(); play(0,-20); play_patch(0,4,1;resonance=0,mask=0); wait!(dt); serial!(str)


end
