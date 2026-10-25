module flopen#(parameter WIDTH = 8) (
	input logic clk, en,
	input logic [WIDTH-1:0] d,
	output logic [WIDTH-1:0] q);
	
	always_ff @(posedge clk)
		if (en) q <= d;
endmodule