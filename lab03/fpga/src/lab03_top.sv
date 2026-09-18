module lab03_top#(
	parameter int count_width = 32,
	parameter int maxcount = 20000000 // Default value is 20 million
)(
	input logic [7:0] switches,
	input logic enable, reset,
	output logic [6:0] display,
	output logic [1:0] seg_power,
	output logic [3:0] scan
);

	//Swtiches worked backwards, flip signal
	logic [7:0] sin;
	assign sin = ~switches;

	// declare an internal clock of 48 Mhz
	logic int_clk;
	HSOSC #(.CLKHF_DIV(2'b00))
		 hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_clk));


	// keypad scanner:
	scanner #(32, 6000000)
		scanner1 (.clk(int_clk), .enable(!enable), .reset(!reset), .scan(scan));

	// debouncer


	// display
	display display_logic(.clk(int_clk), .enable(enablel), .reset(reset),.data(),.display(display),.seg_power(seg_power));
	

endmodule