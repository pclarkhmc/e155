`timescale 1 ns/1 ns

module tb_keypad_reader();

	logic [3:0] cols, key, d0, d1;
	logic clk, reset, scan;
	keypad_reader dut (.cols(cols), .key(key), .clk(clk), .reset(reset), .scan(scan), .d0(d0), .d1(d1));
	
	
	always begin
		clk = 0; #5;
		clk = 1; #5;
	end
	
	initial begin		
		// initial
		reset = 0;
		key = 4'hF;
		cols = 4'b1111;
		
		// bump reset
		reset = 1;
		#20;
		reset = 0;
		#20;
		
		// walk one bit
		key = 2;
		cols = 4'b1110;
		#50;
		cols = 4'b1111;
		#50;
		
		key = 3;
		cols = 4'b1101;
		#50;
		cols = 4'b1111;
		#50;
		
		key = 4;
		cols = 4'b1011;
		#50;
		cols = 4'b1111;
		#50;
		
		key = 5;
		cols = 4'b0111;
		#50;
		cols = 4'b1111;
		#50;
		
		// reset
		reset = 1;
		#20;
		reset = 0;
		#20;
		
		// walk two bits
		key = 6;
		cols = 4'b1100;
		#50;
		cols = 4'b1111;
		#50;
		
		key = 7;
		cols = 4'b1001;
		#50;
		cols = 4'b1111;
		#50;
		
		key = 8;
		cols = 4'b0011;
		#50;
		cols = 4'b1111;
		#50;
		#100
		

		
		$stop;
	end
	
endmodule