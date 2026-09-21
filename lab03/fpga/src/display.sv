module display(
    input logic         clk, enable, reset,
    input logic [7:0]   data,
    output logic [6:0]  display,
    output logic [1:0]  seg_power
);

	// clock divider counter with 100 Hz cycle time
	logic toggle;
    logic [31:0] count;
	counter #(32, 480000)
		counter1(.clk(clk), .reset(reset), .enable(enable), .count(count));
    assign toggle = (count >= 480000>>1);
 
	//muxing logic:
	logic [3:0] seven_comb_in;
	assign seg_power = {toggle, !toggle};
	assign seven_comb_in = toggle ? data[7:4] : data[3:0];

    // instantiate seven segment logic
	seven_seg display1(.switches(seven_comb_in),.seg(display));

endmodule