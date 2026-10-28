/////////////////////////////////////////////
// sim_models
//   simulation-only RotWord/SubWord for testing the AI prototypes.
//   module1 = SubWord and module2 = RotWord under the names used in Prompt 2.
//   The S-box is combinational here ($readmemh), unlike the EBR S-box in lab07_fpga.
/////////////////////////////////////////////

module sbox_comb(
	input  logic [7:0] a,
	output logic [7:0] y
	);

	logic [7:0] sbox [0:255];
	initial $readmemh("sbox.txt", sbox);
	assign y = sbox[a];
endmodule

module rotword(
	input  logic [31:0] a,
	output logic [31:0] y
	);

	assign y = {a[23:0], a[31:24]};
endmodule

module subword(
	input  logic [31:0] a,
	output logic [31:0] y
	);

	sbox_comb s0(.a(a[31:24]), .y(y[31:24]));
	sbox_comb s1(.a(a[23:16]), .y(y[23:16]));
	sbox_comb s2(.a(a[15:8]),  .y(y[15:8]));
	sbox_comb s3(.a(a[7:0]),   .y(y[7:0]));
endmodule

// Prompt 2 names
module module1(
	input  logic [31:0] in,
	output logic [31:0] out
	);

	subword sw(.a(in), .y(out));
endmodule

module module2(
	input  logic [31:0] in,
	output logic [31:0] out
	);

	rotword rw(.a(in), .y(out));
endmodule
