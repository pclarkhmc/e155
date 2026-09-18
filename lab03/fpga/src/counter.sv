/* 
Pierce Clark  pclark@hmc.edu
Counter module with reset, enable, maxcount
*/
module counter#(
	parameter int count_width = 32,
	parameter int maxcount = 20000000 // Default value is 20 million
)(
	input logic clk, reset, enable,
	output logic [count_width-1:0] count
);

	always_ff @(posedge clk) begin
		if(reset) count <= 0;
		else if(count >= maxcount)  count <= 0;
		else if(enable)count <= count + 1;
	end
	
endmodule
