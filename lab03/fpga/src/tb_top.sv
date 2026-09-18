`timescale 1 ns/1 ns

module tb_top();

	logic [7:0] switches;
	logic enable, reset;
	logic [6:0] display;
	logic [1:0] seg_power;
	
	lab02_top #(32, 16)
		dut(.switches(switches), . enable(enable), .reset(reset), .display(display), .seg_power(seg_power));
	
	initial begin
	switches = {4'h4, 4'h6};
	enable = 0; // active low
	reset = 1; // active low
	#1;
	reset = 0;
	#15;
	reset = 1;
	#1000;
	
	$stop;
	end




endmodule