module subbyte_tb();
	
	logic clk, reset, done;
	logic [127:0] a, y;
	
	subbyte DUT(.clk(clk),.reset(reset),.a(a),.y(y),.done(done));

	always begin
		clk = 1; #5;
		clk = 0; #5;
	end
	
	initial begin
		a = 128'h193de3bea0f4e22b9ac68d2ae9f84808;
		reset = 0;
		#5;
		reset = 1;
		#10;
		reset = 0;
		#300;
		$stop;
	end


	

endmodule
