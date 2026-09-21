`timescale 1 ns/1 ns

module tb_keypad_reader();

	logic [3:0] cols, key, d0, d1;
	logic clk, reset, scan;
	keypad_reader dut (.cols(cols), .key(key), .clk(clk), .reset(reset), .scan(scan), .d0(d0), .d1(d1));
	
	initial begin		
		$stop;
	end
	
endmodule