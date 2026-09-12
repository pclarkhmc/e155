module lab02_top(
	input logic [7:0] switches,
	input logic enable, reset,
	output logic [6:0] display,
	output logic [1:0] seg_power
);

	//Swtiches worked backwards, flip signal
	logic [7:0] sin;
	assign sin = ~switches;

	// declare an internal clock of 48 Mhz
	logic int_clk;
	HSOSC #(.CLKHF_DIV(2'b00))
		 hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_clk));
	// clock divider counter
	logic toggle;
	counter #(32, 20000000)
		counter1(.clk(int_clk), .reset(!reset), .enable(!enable), .toggle(toggle));
 
	//muxing logic:
	logic [3:0] seven_comb_in;
	assign seg_power = {toggle, !toggle};
	assign seven_comb_in = toggle ? sin[7:4] : sin[3:0];

	// instantiate seven segment logic
	seven_seg display1(.switches(seven_comb_in),.seg(display));

endmodule