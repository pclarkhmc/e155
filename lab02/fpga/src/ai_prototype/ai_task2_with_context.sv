//------------------------------------------------------------------------------
// ai_task2_with_context.sv
//
// AI prototype, Task 2: generated from the same prompt with the Lab 1 source
// files (lab01_pc.sv, seven_seg.sv, counter.sv) attached as context.
// Kept verbatim as generated for the lab write-up; do not "fix" this copy.
//
// Time multiplexes the single seven_seg decoder from Lab 1 between two nibbles
// and drives two sets of seven segment outputs.  The clock comes from the same
// HSOSC primitive and the divider is the Lab 1 counter module.
//------------------------------------------------------------------------------
module seven_seg_mux(
	input  logic 		reset,
	input  logic [3:0] 	s0,		// first set of input bits
	input  logic [3:0] 	s1,		// second set of input bits
	output logic [6:0] 	seg0,	// first set of seven output bits
	output logic [6:0] 	seg1	// second set of seven output bits
);
	// 48 MHz internal oscillator, same instantiation as lab01_pc
	logic int_osc;
	HSOSC #(.CLKHF_DIV(2'b00))
		hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

	// Reuse the Lab 1 counter as the refresh divider.  Its led output is high
	// for the upper half of the count, so it is a 50% duty square wave.
	// 240,000 counts at 48 MHz is a 5 ms period, i.e. each digit is refreshed
	// at 200 Hz, which is well above the flicker threshold.
	logic select;
	counter #(32, 240000)
		refresh (.clk(int_osc), .reset(!reset), .enable(1'b1), .led(select));

	// Mux the two nibbles into the single shared decoder
	logic [3:0] nibble;
	assign nibble = select ? s1 : s0;

	// One instance of the Lab 1 seven segment decoder for both digits
	logic [6:0] seg;
	seven_seg decoder (.switches(nibble), .seg(seg));

	// Demux the decoder output back out to the two digits
	always_ff @(posedge int_osc) begin
		if (!reset) begin
			seg0 <= 7'b1111111;
			seg1 <= 7'b1111111;
		end else if (select) seg1 <= seg;
		else                 seg0 <= seg;
	end

endmodule
