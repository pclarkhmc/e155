/* 
Pierce Clark  pclark@hmc.edu
The top level module for lab 1, contianing clock
*/
module lab01_pc(
	input logic [3:0] 	s,
	input logic 		reset,
	input logic			enable,
	output logic [2:0] 	led,
	output logic [6:0] 	seg
);
	// Led 0 behavior
	assign led[0] = ^s;
	
	// Led 1 behavior
	assign led[1] = &s;
	
	// Led 2 behavior
	// declare an internal clock of 48 Mhz
	logic int_osc;
	HSOSC #(.CLKHF_DIV(2'b01))
		 hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
	counter #(32, 20000000)
		counter1(int_osc, reset, led[2]);
		 
	// instantiate seven segment logic
	seven_seg display1(s,seg);
	
endmodule