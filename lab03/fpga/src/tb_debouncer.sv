`timescale 1us / 1us

module tb_debouncer();

	logic sw, clk, reset, debounced_sw;
	debouncer #(6) dut(.sw(sw), .clk(clk), .reset(reset), .debounced_sw(debounced_sw));

	always begin
		clk = 0; #5;
		clk = 1; #5;
	end
	
	initial begin
		reset = 0;
		sw = 0;
		#21;
		// simulate switch bouncing
		sw = 1;
		#60
		sw = 0;
		#70
		sw = 1;
		#80
		sw = 0;
		#90
		sw = 1;
		#100
		sw = 0;
		#90
		sw = 1;
		#1000;
		sw = 0;
		#50
		
		// test reset
		sw = 0;
		#90
		sw = 1;
		#500;
		reset = 1;
		#500;
		reset = 0;
		sw = 0;
		#50
		$stop;
	end
endmodule