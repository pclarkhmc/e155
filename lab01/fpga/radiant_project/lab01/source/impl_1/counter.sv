module counter #(
	parameter int count_width = 32,
	parameter int maxcount = 20000000 // Default value is 20 million
)(
	input clk,
	input reset,
	output enable
);
	logic [count_width-1:0] counter;
	always_ff @(posedge clk) begin
		if(reset) counter <= 0;
		else if(counter == maxcount>>1)  counter <= 0;
		else            counter <= counter + 1;
	end
	
	assign enable = (counter >= maxcount>>1);
endmodule
