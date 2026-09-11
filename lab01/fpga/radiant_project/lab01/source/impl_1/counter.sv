/* 
Pierce Clark  pclark@hmc.edu
Counter module with reset, enable, maxcount
*/
module counter #(
	parameter int count_width = 32,
	parameter int maxcount = 20000000 // Default value is 20 million
)(
	input clk,
	input reset,
	input enable,
	output led
);
	
	logic [count_width-1:0] counter;
	
	always_ff @(posedge clk) begin
		if(reset) counter <= 0;
		else if(counter >= maxcount)  counter <= 0;
		else if(enable)counter <= counter + 1;
	end
	
	assign led = (counter >= maxcount>>1);
endmodule
