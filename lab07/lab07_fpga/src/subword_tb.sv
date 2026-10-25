module subword_tb();
	
	logic clk, reset, done;
	logic [31:0] a, y;
	
	subword DUT(.clk(clk),.reset(reset),.a(a),.y(y),.done(done));

	always begin
		clk = 1; #5;
		clk = 0; #5;
	end
	
	initial begin
		//a = 128'h 193de3bea0f4e22b9ac68d2ae9f84808;
		a = 32'hcf4f3c09;
		reset = 0;
		#5;
		reset = 1;
		#20;
		reset = 0;
		#200;
		$stop;
	end


endmodule
