module rotword(
	input logic [31:0] a,
	output logic [31:0] y
	);
	assign y = {a[23:16],a[15:8],a[7:0],a[31:24]};
endmodule
