# Copyright (c) 2024 Toivo Henningsson
# SPDX-License-Identifier: BSD-3-Clause

# Various experiments with playing different sequences using tracks.jl and player.jl

module TryTracks

include("tracks.jl")
include("tt05-synth-serial.jl")
include("player.jl")

make_track(n, dt, s) = Track(parse_track(n, dt, s, 0))
make_track(n, dt, note_offset, s) = Track(parse_track(n, dt, s, note_offset))

n = 8 # Number of time steps. Must be >= number actually used in tracks for make_track to work, the track will be padded to this length.
dt = 256 # Milliseconds per time step
timescale = dt # Used by retigger and envelope time tracks to say what a time of 1 is

# Defaults: empty tracks

track1 = make_track(n, dt, "*/") # melody
track2 = make_track(n, dt, "*/") # bass
track3 = make_track(n, dt, "*/") # bass drum
track4 = make_track(n, dt, "*/") # hihat

track_c = make_track(n, dt, "4") # cutoff
track_r = make_track(n, dt, "2") # res
track_v = make_track(n, dt, "0") # vol
track_cs = make_track(n, dt, "/") # cutoff_sweep
track_rs = make_track(n, dt, "/")
track_vs = make_track(n, dt, "/")
track_cr = make_track(n, dt, "/") # cutoff_rand

track_retrig = make_track(n, dt, "/")
track_cd = make_track(n, dt, "/") # cutoff_delta (applied at retrig)

track_cs1 = make_track(n, dt, "*/") # attack cutoff_sweep
track_cs2 = make_track(n, dt, "*/") # decay cutoff_sweep
track_e1 = make_track(n, dt, "*/") # attack time
track_e2 = make_track(n, dt, "*/") # decay time


#=
track_retrig = make_track(n, dt, "1")
track_cd = make_track(n, dt, "0.5")
track_cr = make_track(n, dt, "6")
=#

#track1 = make_track(n, dt, "C3  ,D3  ,E3  ,F3  ;G3  ,F3  ,E3  ,D3  ;")
#track2 = make_track(n, dt, "C1  ,    ,G1  ,/   ;C1  ,    ,E1  ,/   ;")

#track1 = make_track(n, dt, "C4  ,D4  ,E4  ,F4  ;G4  ,F4  ,E4  ,D4  ;C4")
#track2 = make_track(n, dt, "C2  ,    ,G2  ,/   ;C2  ,    ,E2  ,/   ;C2")

#=
# C major scale with harmonized bass
track1 = make_track(n, dt, "C4  ,D4  ,E4  ,F4  ;G4  ,A4  ,B4  ,    ;C4")
track2 = make_track(n, dt, "G2  ,    ,E2  ,C2  ;    ,E2  ,    ,/   ;C2")
#track2 = make_track(n, dt, "C2  ,G2  ,E2  ,C2  ;G2  ,E2  ,E2  ,/   ;C2")
=#

#=
# C minor scale with harmonized bass
track1 = make_track(n, dt, "C4  ,D4  ,Eb4 ,F4  ;G4  ,Ab4 ,Bb4 ,    ;C4")
track2 = make_track(n, dt, "G2  ,    ,Eb2 ,C2  ;    ,Eb2 ,    ,/   ;C2")
#track2 = make_track(n, dt, "C2  ,G2  ,Eb2 ,C2  ;G2  ,Eb2 ,    ,/   ;C2")
=#


#=
# melody/bass/bass drum/hihat
n = 16
dt = 256
#track1 = make_track(n, dt, "C4,  ,/ ,  ;F4,  ,G4,  ;F4,  ,A4,  ;  ,  ,E4,  ;C4")  # melody
#track2 = make_track(n, dt, "/ ,C2,/ ,C3;/ ,C2,/ ,G2;/ ,C2,/ ,E2;/ ,  ,  ,B2;C2")  # bass
#track2 = make_track(n, dt, "/ ,C3,/ ,C2;/ ,C3,/ ,G3;/ ,C3,/ ,E3;/ ,  ,  ,B3;C3")  # bass (raised one octave)
track1 = make_track(n, dt, "C4,  ,  ,  ;F4,/ ,G4,  ;F4,  ,Ab4, ;  ,/ ,Eb4,  ;C4")  # melody (minor)
#track2 = make_track(n, dt, "/ ,C2,/ ,C3;/ ,C2,/ ,G2;/ ,C2,/ ,Eb2; ,/ ,  ,Bb2;") # bass (minor)
track2 = make_track(n, dt, "/ ,C3,/ ,C2;/ ,C3,/ ,G3;/ ,C3,/ ,Eb3; ,/ ,  ,Bb3;C3") # bass (minor, octave+)
track3 = make_track(n, dt, "C4,  ,  ,  ;+ ,  ,  ,  ;+ ,  ,  ,  ;+ ,+ ,  ,  ;*/") # bass drum
track4 = make_track(n, dt, "  ,  ,C8,  ;  ,  ,+ ,  ;  ,  ,+ ,  ;  ,  ,+ ,  ;")  # hihat
track_r = make_track(n,dt, "1 ,  ,  ,  ;0 , ,  ,  ;1  ,  ,  ,  ;2 ,  ,  ,  ;1") # varying resonance
track_c = make_track(n,dt, "2 ,  ,  ,  ;1 , ,0.5, ;0  ,  ,1 ,  ;2 ,  ,  ,  ;1") # varying cutoff

track_cs = make_track(n, dt, "9") # cutoff_sweep

#track_retrig = make_track(n,dt, "1, , ,;/ ,  , ,  ;   ,  ,  ,  ;0.5 ,  ,  ,  ;")
=#


#=
# S&H cutoff fifths
n = 5
dt = 1024*2

offs = -4


#track1 = make_track(n, dt, "A2, C3, F2, G2, A2,/")
#track2 = make_track(n, dt, "E2, G2, C3, D3, E2,/")

#track1 = make_track(n, dt, "A2, B2, F2, G2, A2,/")
#track2 = make_track(n, dt, "E2, E2, C3, D3, E2,/")

#track1 = make_track(n, dt, offs, "E3, E3, F3, G3, E3,/")
#track2 = make_track(n, dt, offs, "A2, B2, C3, D3, A2,/")


offs = -2*12 - 4; n = 4*16; dt = 124
#track1 = make_track(n, dt, offs, "  E5,,    ,;    ,,    ,;    ,,    ,;    ,,    ,|  E5,,*F#5,; *E5,,*F#5,; *E5,,*F#5,; *E5,,*F#5,|  C5,,    ,;    ,,    ,;    ,,    ,;    ,,    ,|  D5,,    ,;    ,,    ,;    ,,    ,;    ,,    ,|E5")
#track2 = make_track(n, dt, offs, "  A4,, *B4,; *A4,, *B4,;  A4,, *B4,; *A4,, *B4,|  B4,,    ,;    ,,    ,;    ,,    ,;    ,,    ,|  F4,, *G4,; *F4,, *G4,; *F4,, *G4,; *F4,, *G4,|  G4,, *A4,; *G4,, *A4,; *G4,, *A4,; *G4,, *A4,|A4")
#track1 = make_track(n, dt, offs, "  E5,,    ,;    ,,    ,;    ,,    ,;    ,,    ,|  E5,,     ;    ,,    ,; *E5,,*F#5,; *E5,,*F#5,|  C5,,    ,;    ,,    ,;    ,,    ,;    ,,    ,|  D5,,    ,;    ,,    ,;    ,,    ,;    ,,    ,|E5")
#track2 = make_track(n, dt, offs, "  A4,,    ,;    ,,    ,;  A4,, *B4,; *A4,, *B4,|  B4,,    ,;    ,,    ,;    ,,    ,;    ,,    ,|  F4,,    ,;    ,,    ,; *F4,, *G4,; *F4,, *G4,|  G4,,    ,;    ,,    ,; *G4,, *A4,; *G4,, *A4,|A4")
#track1 = make_track(n, dt, offs, "  E5,,    ,;    ,,    ,;    ,,    ,; *C5,,  E5,|  E5,,     ;    ,,    ,; *E5,,*F#5,; *G5,,*F#5,|  C5,,    ,;    ,,    ,;    ,,    ,; *D5,, *C5,|  D5,,    ,;    ,,    ,;    ,,    ,; *E5,, *D5,|E5")
#track2 = make_track(n, dt, offs, "  A4,,    ,;    ,,    ,;  A4,, *B4,; *G4,, *B4,|  B4,,    ,;    ,,    ,;    ,,    ,; *D5,, *B4,|  F4,,    ,;    ,,    ,; *F4,, *G4,; *A4,, *G4,|  G4,,    ,;    ,,    ,; *G4,, *A4,; *B4,, *A4,|A4")
track1 = make_track(n, dt, offs, "  E5,,    ,;    ,,    ,;    ,,    ,; *C5,, *E5,|  E5,,     ;    ,,    ,; *E5,,*F#5,; *G5,,*F#5,|  C5,,    ,;    ,,    ,;    ,,    ,; *D5,, *C5,|  D5,,    ,;    ,,    ,;    ,,    ,; *E5,, *D5,|E5")
track2 = make_track(n, dt, offs, "  A4,,    ,;    ,,    ,;  A4,,  B4,;  G4,,  B4,|  B4,,    ,;    ,,    ,;    ,,    ,;  D5,,  B4,|  F4,,    ,;    ,,    ,;  F4,,  G4,;  A4,,  G4,|  G4,,    ,;    ,,    ,;  G4,,  A4,;  B4,,  A4,|A4")


track_retrig = make_track(n, dt, "1")
track_c = make_track(n, dt, "7") # cutoff
track_r = make_track(n, dt, "2") # res
track_cd = make_track(n, dt, "1")
track_cr = make_track(n, dt, "-1")
track_cs = make_track(n, dt, "11") # cutoff_sweep
=#

#=
# Power chords
n = 5*8
dt = 128
#track1 = make_track(n, dt, "A2,, B2,/, A2,, B2,/, C3,, D3,/, C3,, D3,/, F2,, G2,/, F2,, G2,/, G2,, A2,/, G2,, A2,/, A2,, B2,/, A2,, B2,/,")
#track2 = make_track(n, dt, "E2,, E2,/, E2,, E2,/, G2,, G2,/, G2,, G2,/, C3,, C3,/, C3,, C3,/, D3,, D3,/, D3,, D3,/, E2,, E2,/, E2,, E2,/,")

# raised one octave
#track1 = make_track(n, dt, "A3,, B3,/, A3,, B3,/, C4,, D4,/, C4,, D4,/, F3,, G3,/, F3,, G3,/, G3,, A3,/, G3,, A3,/, A3,, B3,/, A3,, B3,/,")
#track2 = make_track(n, dt, "E3,, E3,/, E3,, E3,/, G3,, G3,/, G3,, G3,/, C4,, C4,/, C4,, C4,/, D4,, D4,/, D4,, D4,/, E3,, E3,/, E3,, E3,/,")

# changed rhythm
track1 = make_track(n, dt, "A3,/, B3,/, A3,, B3,/, C4,/, D4,/, C4,, D4,/, F3,/, G3,/, F3,, G3,/, G3, A3, G3, /, G3,, A3,/, A3,/, B3,/, A3,, B3,/,")
track2 = make_track(n, dt, "E3,/, E3,/, E3,, E3,/, G3,/, G3,/, G3,, G3,/, C4,/, C4,/, C4,, C4,/, D4, D4, D4, /, D4,, D4,/, E3,/, E3,/, E3,, E3,/,")

# changed rhythm + Amin7 chord
#track1 = make_track(n, dt, "A3,/, C4,/, A3,, C4,/, C4,/, D4,/, C4,, D4,/, F3,/, G3,/, F3,, G3,/, G3, A3, G3, /, G3,, A3,/, A3,/, B3,/, A3,, B3,/,")
#track2 = make_track(n, dt, "E3,/, G3,/, E3,, G3,/, G3,/, G3,/, G3,, G3,/, C4,/, C4,/, C4,, C4,/, D4, D4, D4, /, D4,, D4,/, E3,/, E3,/, E3,, E3,/,")

# raised a half octave
#track1 = make_track(n, dt, "A2,/, B2,/, A2,, B2,/, C3,/, D3,/, C3,, D3,/, F3,/, G3,/, F3,, G3,/, G3, A3, G3, /, G3,, A3,/, A2,/, B2,/, A2,, B2,/,")
#track2 = make_track(n, dt, "E3,/, E3,/, E3,, E3,/, G3,/, G3,/, G3,, G3,/, C3,/, C3,/, C3,, C3,/, D3, D3, D3, /, D3,, D3,/, E3,/, E3,/, E3,, E3,/,")

# with Amin7 chord
#track1 = make_track(n, dt, "A3,, C4,/, A3,, C4,/, C4,, D4,/, C4,, D4,/, F3,, G3,/, F3,, G3,/, G3,/, A3,, G3,/, A3,, A3,, B3,/, A3,, B3,/,")
#track2 = make_track(n, dt, "E3,, G3,/, E3,, G3,/, G3,, G3,/, G3,, G3,/, C4,, C4,/, C4,, C4,/, D4,/, D4,, D4,/, D4,, E3,, E3,/, E3,, E3,/,")

track_c = make_track(n, dt, "2") # cutoff
track_v = make_track(n, dt, "5") # cutoff
track_cs = make_track(n, dt, "9") # cutoff_sweep
=#


# Brass-like
n = 1
dt = 1024
timescale = 128
track1 = make_track(n, dt, "C3,")
track2 = make_track(n, dt, "C3,")
track_r = make_track(n, dt, "1") # res
track_c = make_track(n, dt, "0") # cutoff
track_cs1 = make_track(n, dt, "-6") # attack cutoff_sweep
track_cs2 = make_track(n, dt, "8") # decay cutoff_sweep
track_cs = make_track(n, dt, "11") # cutoff_sweep
track_e1 = make_track(n, dt, "1") # attack time
track_e2 = make_track(n, dt, "4") # decay time




# Put the tracks together
track_default = make_track(0, 1, "*/")
state = State(timescale, Dict([
	:t1 => track1, :t2 => track2, :t3 => track3, :t4 => track4, :c => track_c, :r => track_r, :v => track_v, :cs => track_cs, :cr => track_cr,
	:retrig => track_retrig, :cd => track_cd,
	:cs1 => track_cs1, :cs2 => track_cs2, :e1 => track_e1, :e2 => track_e2,
	:wf2 => make_track(n, dt, "3"),
	:default => track_default
]))

# Gather the command string
str = play!(state)
println("serial!(", repr(str), ")\n")

# Try to reset the synth state and then play the sequence

# sweep_off(); play_patch(0, 4, 6; vol=2) # clearly audible sound
sweep_off(); play(0,-20); play_patch(0,4,1;resonance=0,mask=0); wait!(dt); serial!(str)


end
