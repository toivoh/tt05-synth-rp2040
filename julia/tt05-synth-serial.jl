# Copyright (c) 2024 Toivo Henningsson
# SPDX-License-Identifier: BSD-3-Clause

# Serial output functions to send commands to the RP2040 to write register values and wait.
# Many of the functions can be called without an io, which opens the serial port and sends the data,
# or with an io, which can be serial port, or used to print or collect the command string for later.


using LibSerialPort


# It seems that the port needs to be opened once in PuTTY before it can be opened from here?

# Modify these as needed
portname = "COM8"
baudrate = 115200

hex(x::Integer, n::Int) = string(x; base = 16, pad = n)


abstract type Regs; end
const IORegs = Union{IO, Regs}


function serial_open(f)
	LibSerialPort.open(portname, baudrate) do sp
		retval = f(sp)
		return retval
	end
end


waitecho(io::IO) = nothing
function waitecho(io::SerialPort)
	# wait for an echo for each byte, then read any additional output
	read(io, UInt8); while bytesavailable(io) > 0; read(io, UInt8); end
end


# Send a string to the serial port given by io.
# Relies on the echo provided by the serial code for the RP2040. Things seem to break when the RP2040 executes a wait, unless we wait for the echo.
function serial_out!(io::IO, str::String)
	for c in str
		write(io, UInt8(c))
		waitecho(io)
	end
end

serial!(str::String) = serial_open() do sp; serial_out!(sp, str) end


# Send a wait command
function wait!(io::IO, ms::Integer)
	@assert 0 <= ms <= 4095
	#print(io, 'w', hex(ms, 1), ' ')

	str = string('w', hex(ms, 1), ' ')
	serial_out!(io, str)
end

wait!(ms::Int) = serial_open() do sp; wait!(sp, ms); end


# Set n consecutive registers. Not sure how high values of n that the C code handles, but up to 4 is fine.
function set_reg!(io::IO, addr::Int, value::Integer, n::Int)
	print(io, 'r', hex(addr&15, 1))
	@assert 1 <= n <= 4
	@assert value >> (8*n) == 0
	for i=n-1:-1:0
		print(io, '_', hex((value >> (8*i)) & 255, 2))
	end
	print(io, ' ')
	waitecho(io)
end

set_reg!(addr::Int, value::Integer, n::Int) = serial_open() do sp; set_reg!(sp, addr, value, n); end

set_reg8!(args...) = set_reg!(args..., 1)
set_reg16!(args...) = set_reg!(args..., 2)
set_reg32!(args...) = set_reg!(args..., 4)


# Set filter parameters.
#
# cutoff, vol, and resonance can be floating point, and are multiplied by 32.
# cutoff is a period, lower value means higher cutoff.
# resonance and vol are adjusted relative to cutoff.
function patch(io::IORegs, cutoff, vol=0, resonance=0)
	cutoff = round(Int, 32cutoff)
	vol = round(Int, 32(vol-2))
	resonance = round(Int, 32resonance)

	resonance += cutoff
	vol_p = cutoff-vol

	# Avoid saturation: back off from minimum period
	m = min(0, cutoff, resonance, vol_p)
	cutoff = min(cutoff - m, 0x1ff)
	resonance = min(resonance - m, 0x1ff)
	vol_p = min(vol_p - m, 0x1ff)

	set_reg16!(io, 4, cutoff) # cutoff period
	set_reg16!(io, 6, resonance) # damp period
	set_reg16!(io, 8, vol_p) # vol period
end

patch(cutoff, vol=0, resonance=0) = serial_open() do sp; patch(sp, cutoff, vol, resonance); end

# Set oscillator period for one or more oscillators, mask decides which to set.
function play(io::IORegs, note::Int, oct::Int, detune::Int=2, mask::Int=3)
	note += 12*(oct + 9)
	oct, note = note ÷ 12, note % 12
	oct = 15 - oct

	if oct < 0;  oct = 0; note = 11;  end
	p = round(Int, 512 * 2^((11 - note)/12))
	if oct > 15;  oct = 15; p = 1023;  end

	f = (oct << 9) | (p & 511)
	f2 = min(0x1fff, max(0, f+detune))
	if mask & 1 != 0; set_reg16!(io, 0, f);   end # period1
	if mask & 2 != 0; set_reg16!(io, 2, f2);  end # period2
	return oct, p, f
end

play(note::Int, oct::Int, detune::Int=2, mask::Int=3) = serial_open() do sp; play(sp, note, oct, detune, mask); end


# Like play, but with an offset in semitones between the two oscillators.
function play_interval(io::IORegs, note::Int, oct::Int, interval::Int, detune::Int=2)
	play(io, note+interval, oct, detune, 2)
	return play(io, note, oct, detune, 1)
end

play_interval(note::Int, oct::Int, interval::Int, detune::Int=2) = serial_open() do sp; play_interval(sp, note, oct, interval, detune); end


# Combination of play and patch
# - makes cutoff relative to current note
# - makes higher cutoff correspond to higher cutoff frequency
function play_patch(io::IORegs, note::Int, oct::Int, cutoff; detune::Int=2, mask::Int=3, vol=0, resonance=0)
	oct, p, f = play(io, note, oct, detune, mask)
	cutoff = -cutoff
	cutoff += f/512 + 2
	patch(io, cutoff, vol, resonance)
end

play_patch(note::Int, oct::Int, cutoff; detune::Int=2, mask::Int=3, vol=0, resonance=0) = serial_open() do sp; play_patch(sp, note, oct, cutoff; detune=detune, mask=mask, vol=vol, resonance=resonance); end


# Combination of play_interval and patch, much like play_patch
function play_interval_patch(io::IORegs, note::Int, oct::Int, interval::Int, cutoff; detune::Int=2, mask::Int=3, vol=0, resonance=0)
	oct, p, f = play_interval(io, note, oct, interval, detune)
	cutoff = -cutoff
	cutoff += f/512 + 2
	patch(io, cutoff, vol, resonance)
end

play_interval_patch(note::Int, oct::Int, interval::Int, cutoff; detune::Int=2, mask::Int=3, vol=0, resonance=0) = serial_open() do sp; play_interval_patch(sp, note, oct, interval, cutoff; detune=detune, mask=mask, vol=vol, resonance=resonance); end


const WF_PULSE = 0
const WF_SQUARE = 1
const WF_NOISE = 2
const WF_SAW = 3

# Set waveform and whether to use lowpass or bandpass filter for each oscillator
function waveform(io::IORegs, wf1::Int, wf2::Int=-1; bpf=0, bpf2=-1)
	if (wf2 == -1);  wf2 = wf1;  end
	if (bpf2 == -1);  bpf2 = bpf;  end
	wf1 &= 3
	wf2 &= 3
	bpf &= 1
	bpf2 &= 1

	#out = wf1 | (wf2 << 2) | 192
	out = wf1 | (wf2 << 2) | (xor(bpf2 << 1 | bpf, 3) << 6)
	#@show UInt8(out)
	set_reg8!(io, 15, out) # cfg
end

waveform(wf1::Int, wf2::Int=-1; bpf=0, bpf2=-1) = serial_open() do sp; waveform(sp, wf1, wf2; bpf=bpf, bpf2=bpf2); end


# Set sweep rate for a register.
# addr specifies the register to set the sweep rate for, not the sweep rate register.
function sweep(io::IORegs, addr::Int, sign::Int, rate::Real)
	@assert 0 <= sign <= 1
	rate = round(Int, 8rate)
	@assert 0 <= rate <= 127
	@assert 0 <= addr <= 8
	@assert addr&1 == 0
	addr = (addr >> 1) + 10
	set_reg8!(io, addr, (sign << 7) | rate)
end

sweep(addr::Int, sign::Int, rate::Int) = serial_open() do sp; sweep(sp, addr, sign, rate); end


# Sweep the cutoff frequency without affecting the resonance or volume.
function sweep_c(io::IORegs, sign::Int, rate::Real)
	sweep(io, 4, sign, rate)
	sweep(io, 6, sign, rate)
	sweep(io, 8, sign, rate)
end

sweep_c(sign::Int, rate::Int) = serial_open() do sp; sweep_c(sp, sign, rate); end


# Turn off sweep for a given register.
function sweep_off(io::IORegs, addr::Int)
	@assert addr&1 == 0
	addr = (addr >> 1) + 10
	set_reg8!(io, addr, 0xff)
end

sweep_off(addr::Int) = serial_open() do sp; sweep_off(sp, addr); end

# Turn off all sweeps
sweep_off(io::IORegs) = for i=0:2:8; sweep_off(io, i); end
sweep_off() = serial_open() do sp; sweep_off(sp); end
