`timescale 1 ns/1 ns

module tb_scanner();
	logic clk, enable, reset;
	logic [3:0] scan;
	
	//max count 5 for testing
	scanner #(32, 5)
		dut (.clk(clk), .enable(enable), .reset(reset), .scan(scan));
	
	always begin
		clk = 0; #5;
		clk = 1; #5;
	end
		
	// apply stimuli and check inputs
	// cycle through all the states
	initial begin
		enable = 1;
		reset = 0;
		#1;
		reset = 1;
		#15;
		reset = 0;
		#350;
		
		// test reset
		reset = 1;
		#50;
		assert(scan == 4'b0001);
		reset = 0;
		#50;

		// test enable
		enable = 0;
		#50;
		enable = 1;
		#100;
		$stop;
	end
  
endmodule