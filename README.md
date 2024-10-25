Play utilities and demo tune for tt05-synth
===========================================
This firmware using the Pico C SDK is meant to run on the [Tiny Tapeout 5](https://tinytapeout.com/runs/tt05/) demo board to control my https://github.com/toivoh/tt05-synth synth chip project in TT05.
It is based on Michael Bell's excellent [Tiny Tapeout 04+ demo board C example](https://github.com/MichaelBell/tt05-rp2040).
See the Raspberry Pi [Getting Started with Pico](https://datasheets.raspberrypi.com/pico/getting-started-with-pico.pdf) guide for information on how to get set up to build the firmware.

This repository contains:
- RP2040 firmware that selects `tt05-synth`, clocks it at 50 MHz, and receives commands over USB UART to set synth registers or wait a given amount of time
- [Julia](https://julialang.org/) code for creating command strings to the synth (including the demo tune) and sending them a serial port

A recording of the demo tune played on the `tt05-synth` hardware can be found at https://youtu.be/ed3JROdFSls.

Serial receiver
---------------
After building the firmware, to upload it to the demo board, follow the instructions at https://tinytapeout.com/guides/get-started-demoboard/#ossdk-updates, except use the UF2 file produced in the firmware build instead. Follow the original instructions upload the latest verison of the default firmware to the demo board.

If you just want to play the demo tune, you can upload the firmware to the demo board, open a serial terminal to the demo board, copy the contents of [demo-tune-commands.txt](demo-tune-commands.txt) and paste the whole string into the serial terminal. The terminal will be busy for around 2 minutes while the demo tune plays.

The serial receiver receives commands as text over USB UART, which can be used to set registers in the synth, and wait for a specified amount of time.
You can supply a sequence of commands:
- `wNN`: wait NN milliseconds, at most `fff`.
- `rRNN`: write register R with value `NN` (2 hex digits for `NN`).
- `rRNNN` and `rRNNNN` (3 / 4 hex digits for `NN`) continues to write the higher bytes to consecutive registers, etc. At least 4 consectutive registers can be written this way.
- `rRNN` can also be spelled as `rRvNN`.

where `R` is a single hex digit and `NN` = any hex number of length >= 1.
Any non-hexdigit character ends the command, except `_` which can be used to delimit groups of hex digits.

For documentation of what the registers do, see https://tinytapeout.com/runs/tt05/tt_um_toivoh_synth.

*TODO:* Before writing to one of the registers 0 to 9, the corresponding sweep register should be disabled by writing `0xff` to it.
The registers 0 to 9 are actually five 16 bit registers; both halves of a 16 bit register should be updated before restarting the sweep by writing the desired sweep value to the corresponding sweep register.
Updating a register pair while its sweep is active may result in the wrong value being used, since the sweep might update the register pair between writing the first and second half.
This did not turn out to be a serious problem for the demo tune, so it has not been implemented. It mostly seems to have an effect for very fast sweeps. If you experience unexpected or nondeterministic behavior, this might be the cause.
If register pairs are always written using a single `rNNNN` command, the serial receiver could be made to clear the sweep before the write and restore it afterwards.
Alternatively, the command sequence could be altered to disable the appropriate sweeps before updating 16 bit registers, and restoring them afterwards.

Julia code
----------
`tt05-synth-serial.jl` contains code to create serial commands for different purposes and output them as strings or send them to a serial port.
Close to the top are definitions

	portname = "COM8"
	baudrate = 115200

Modify them if they do not match your setup.
These functions are good for interactive experimentation with the synth. Many have small comments about what they do.

To make the serial connection from Julia work (in windows), I had to plug in the TT05 demo board, then connect with PuTTY to the serial port and close it before trying to use serial communications from inside Julia.
The example files print the serial commands before sending them to the serial port, if you don't want to connect to the serial port from within Julia, you can copy the printed command string instead (everything within quotes) and paste it into a serial terminal connected to the TT05 board instead.

`tracks.jl` and `player.jl` contain infrastructure for writing music using tracks represented with text strings. The features implemented are those that were needed for the demo tune.
Track format:

	Example:  track = parse_track(8,2," C1, *E1 , G1,, +,, *10")
	- Note names and numbers start an interval, last until the next interval is started
	- ,;| take one time step
	- * before a start turns off the trigger. This works for some cases and some kinds of tracks, and leaves the interval without effect for others.
	- + starts a new interval with the last value
	- / sets the the value to NOTHING, can be used as a note-off

	parse_track(nsteps::Int, step_size::Int, str::String, ...):
	Max nsteps time steps are expected, the last interval is filled up to that length.
	Each time step adds a wait time of step_size.

`try_tracks.jl` contains various smaller examples of sequences.
`demo-tune.jl` contains the actual demo tune. When you run it, it tries to send the demo tune command sequence to the serial port.
