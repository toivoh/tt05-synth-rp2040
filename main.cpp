#include <pico/stdlib.h>
#include <hardware/sync.h>
#include <pico/multicore.h>

#include <array>
#include <cstdio>

#include "hardware/pwm.h"
#include "stdlib.h"
#include <tusb.h>

#include "tt_setup.h"
#include "tt_pins.h"

#define DESIGN_NUM 262

#define WRITE_STROBE UIO7


// print(round.(Int, (2 .^((0:11)/12) .- 1)*512))
const int period_table[12] = {0, 30, 63, 97, 133, 171, 212, 255, 301, 349, 400, 455};


static inline void wait() {
	/*
	uint64_t time = time_us_64();

	while (true) {
		uint64_t dt = time_us_64() - time;

		if (dt > 1) break;
	}
	*/
}


bool manual_clock = true;

void tt_clock_project_n(int n) {
	for (int i = 0; i < n; i++) {
		tt_clock_project_once();
		//sleep_ms(63);
	}
}


void set_reg8(int addr, int value) {
	addr &= 15;

	for (int i=0; i < 1; i++) {
		tt_set_input_byte(value);
		tt_set_bidir_byte(addr);

		if (manual_clock) tt_clock_project_n(8);
		//else for (int i=0; i < 9; i++) tt_set_bidir_byte(addr);
		else wait();

		tt_set_bidir_byte(addr | 128); // strobe
		if (manual_clock) tt_clock_project_n(16); // 10 should be enough
		//else for (int i=0; i < 9; i++) tt_set_bidir_byte(addr | 128);
		else wait();

		tt_set_bidir_byte(addr); // release strobe
		if (manual_clock) tt_clock_project_n(8);
		//else for (int i=0; i < 9; i++) tt_set_bidir_byte(addr);
		else wait();
	}
}

void set_reg16(int addr, int value) {
	set_reg8(addr, value & 255);
	set_reg8(addr+1, (value >> 8) & 255);
}

int note_to_period(int note) {
	note = 6*12 - note;

	int oct = note / 12;
	note %= 12;

	if (oct < 0) { oct = 0; note = 0; }
	else if (oct > 15) oct = 15;

	return period_table[note] | ((oct & 15) << 9);
}

void note_off() {
	set_reg16(0, -1);
	set_reg16(2, -1);
}

void play(int note, int detune = 2) {
	int period1 = note_to_period(note);
	int period2 = period1 + detune;
	if (period2 < 0) period2 = 0;
	else if (period2 > 0x1fff) period2 = 0x1fff;

	set_reg16(0, period1);
	set_reg16(2, period2);
}


/*
Serial format:
NN = any hex number of length >= 1

wNN: wait NN milliseconds, at most fff.
rRNN: write register R with NN.
rRNNN and rRNNNN continues to write the higher bytes to consecutive registers, etc...
rRNN can also be spelled as rRvNN.

Any non-hexdigit character ends the command, except _ which can be used to delimit groups of hex digits.
*/
void serial_receiver() {
	char cmd = 0;
	int addr = 0;
	int data = 0;
	int count = 0;
	while (true) {
		while (tud_cdc_available()) {

			bool print_prompt = false;

			char c = getchar();
			//printf("c = %d\r\n", c);

			int hex_digit = -1;
			if ('0' <= c && c <= '9') hex_digit = c - '0';
			if ('a' <= c && c <= 'f') hex_digit = c - 'a' + 10;
			if ('A' <= c && c <= 'F') hex_digit = c - 'A' + 10;

			if (hex_digit >= 0) {
				if (cmd == 'r') {
					addr = hex_digit;
					cmd = 'v';
					data = count = 0;
				} else {
					count += 1;
					data = (data << 4) | hex_digit;
				}
			} else if (c != '_') {
				if (count > 0) {
					//printf("\tcmd = %c, data = 0x%x, count = %d", cmd, data, count);

					if (cmd == 'w') sleep_ms(data & 4095);
					else if (cmd == 'v') {
						if (count > 32) count = 32; // data won't hold 32 hex digits, though
						for (int i = 0; i*2 < count; i++) {
							int reg = (addr + i) & 15;
							int byte = data & 255;
							set_reg8(reg, byte);
							//printf("set reg%d = 0x%x\r\n", reg, byte);
							data >>= 8;
						}
					}
					print_prompt = true;
				} else if (c == '\r' || c == '\n') print_prompt = true;

				if (c == 'r' || c == 'v' || c == 'w') cmd = c;

				count = 0;
				data = 0;
			}

			if (c >= 32) printf("%c", c);
			//else printf("c = %d\r\n", c);
			else printf(" ");

			if (print_prompt) printf("\r\n>> ");
		}
	}
}


int main() {
	// tt05-synth is designed to be clocked at 50 MHz, so we need to clock the RP2040 at twice that, 100 MHz
	// so that we can use the PWM to clock the RP2040.
	set_sys_clock_khz(100000, true);
	//set_sys_clock_khz(133000, true);

	stdio_init_all();

	// Uncomment to pause until the USB is connected before continuing
	//while (!stdio_usb_connected());

	sleep_ms(20);
	printf("TT05 synth\n");
	sleep_ms(10);

	// leaves design in reset
	tt_select_design(DESIGN_NUM);
	printf("Selected\n");
	sleep_ms(10);


	// Clock in reset
	tt_clock_project_n(10);


	// Set bidir directions
	// write address
	gpio_set_dir(UIO0, true); gpio_set_dir(UIO1, true); gpio_set_dir(UIO2, true); gpio_set_dir(UIO3, true);
	// write strobe
	gpio_set_dir(WRITE_STROBE, true);
	gpio_put(WRITE_STROBE, 0);


	// Take out of reset
	gpio_put(SDI_nRST, 1);

	// TODO: PWM clock.
	// manual_clock = false;

	set_reg16(0, 3 << 9); // period1
	set_reg16(2, (3 << 9) + 2); // period2
	for (int i = 4; i < 10; i++) set_reg8(i, 0); // set cutoff/damp/vol periods to minimum
	for (int i = 10; i < 16; i++) set_reg8(i, 255);


	// Set up TT clock using PWM
	// =========================
	manual_clock = false;
	gpio_set_function(CLK, GPIO_FUNC_PWM);
	uint tt_clock_slice_num = pwm_gpio_to_slice_num(CLK);

	// Period 2, one cycle low and one cycle high
	pwm_set_wrap(tt_clock_slice_num, 1);
	pwm_set_chan_level(tt_clock_slice_num, CLK & 1, 1);
	// The clock doesn't start until the pwm is enabled
	// Enable the PWM, starts the TT clock
	pwm_set_enabled(tt_clock_slice_num, true);


	serial_receiver();

/*
	while (1) {
		//for (int i = 0; i < 16; i++) set_reg8(i, rand() & 255);

		if (manual_clock) {
			tt_clock_project_n(1);
			tt_clock_project_n(5000000);
		}
	}
	*/
	int d = 250;
	while (true) {
		for (int i = 0; i < 3; i++) {
			int offs = 0;
			if (i == 1) offs = 5;
			if (i == 2) offs = 7;

			for (int j=0; j < 4; j++) {
				play(3*12 + ((0 + offs) % 12)); sleep_ms(d);
				play(3*12 + ((4 + offs) % 12)); sleep_ms(d);
				play(3*12 + ((7 + offs) % 12)); sleep_ms(d);
			}
		}
		//play(3*12 - 1); sleep_ms(d);
		//note_off(); sleep_ms(d);
	}
}
