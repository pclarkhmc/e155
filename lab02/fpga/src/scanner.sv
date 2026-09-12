module scanner(
	input clk, enable, reset,
	output [3:0] scan
	);
	
	logic toggle;
	counter #(32, 6000000)
		counter1(.clk(int_clk), .reset(!reset), .enable(!enable), .toggle(toggle));
	logic [4:0] state;
	always_ff @(posedge toggle) begin
		if (reset) state <= 4'b0001;
		else if(enable) begin
			case (state)
				4'b0001: state <= 4'b0010;
				4'b0010: state <= 4'b0100;
				4'b0100: state <= 4'b1000;
				4'b1000: state <= 4'b0001;
				default: state <= 4'b0001;
			endcase
			end
		end
endmodule