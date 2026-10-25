module keyexpansion_controller_tb();

	logic clk, en, reset;
	logic [3:0] round;
	logic [127:0] key_in, key_out;
	keyexpansion_controller DUT(.clk(clk), .en(en), .reset(reset), .round(round),.key_in(key_in),.key_out(key_out));
	
	always begin
		clk = 1; #2;
		clk = 0; #2;
	end
	
	
	initial begin
		round = 0;
		en = 1;
		key_in = 128'h2B7E151628AED2A6ABF7158809CF4F3C;
		#4;
		reset = 1;
		#4;
		reset = 0;
		
		#4;
		round = 1;
		#4;
		round = 2;
		#4;
		round = 3;
		#4;
		round = 4;
		#4;
		round = 5;
		#4;
		round = 6;
		#4;
		round = 7;
		#4;
		round = 8;
		#4;
		round = 9;
		#4;
		round = 10;
		#4;
		$stop;
	end
endmodule 