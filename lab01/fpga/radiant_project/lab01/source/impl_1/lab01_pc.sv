/* 
Pierce Clark  pclark@hmc.edu
Top level module for lab01 E155 HMC
*/
module lab01_pc(
	input logic [3:0] 	s,
	input logic 		reset,
	input logic			enable,
	output logic [2:0] 	led,
	output logic [6:0] 	seg
);
	//Swtiches worked backwards, flip signal
	logic [3:0] sin;
	assign sin = ~s;
	// Led 0 behavior
	assign led[0] = ^sin[1:0];
	
	// Led 1 behavior
	assign led[1] = &sin[3:2];
	
	// Led 2 behavior
	// declare an internal clock of 48 Mhz
	logic int_osc;
	HSOSC #(.CLKHF_DIV(2'b01))
		 hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));
	counter #(32, 20000000)
		counter1(.clk(int_osc), .reset(!reset), .enable(!enable), .led(led[2]));
		 
	// instantiate seven segment logic
	seven_seg display1(.switches(sin),.seg(seg));
	
endmodule