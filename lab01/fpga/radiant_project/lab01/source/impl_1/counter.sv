module counter(
#(
	parameter int Hz
)(
	input clk,
	input reset,
	output enable
);

	always_ff @(posedge int_osc) begin
		if(reset) counter <= 0;
		else if(counter == 8'd20000000)  counter <= 0;
		else            counter <= counter + 1;
	end
	
	assign enable = (counter >= 8'd10000000)
endmodule