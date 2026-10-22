module rcon(
	input logic [3:0] j,
	output logic [31:0] y
	);
	always_comb begin
		case (j) 
			1 : y = 32'h01000000;
			2 : y = 32'h02000000;
			3 : y = 32'h04000000;
			4 : y = 32'h08000000;
			5 : y = 32'h10000000;
			6 : y = 32'h20000000;
			7 : y = 32'h40000000;
			8 : y = 32'h80000000;
			9 : y = 32'h1b000000;
			10 : y = 32'h36000000;
			default: y = 32'h00000000; // Catch-all condition
		endcase
	end
endmodule