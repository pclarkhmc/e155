module keyexpansion_controller_tb();

	logic clk, en, reset;
	logic [3:0] round;
	logic [127:0] key_in, key_out;
	keyexpansion_controller DUT(.clk(clk), .en(en), .reset(reset), .round(round),.key_in(key_in),.key_out(key_out));
	
	always begin
		clk = 0; #2;
		clk = 1; #2;
	end
	
	
	initial begin
		round = 0;
		en = 1;
		key_in = 128'h2B7E151628AED2A6ABF7158809CF4F3C;
		#5;
		reset = 1;
		#5;
		reset = 0;
		
		#5;
		round = 1;
		#5;
		round = 2;
		#5;
		round = 3;
		#5;
		round = 4;
		#5;
		round = 5;
		#5;
		round = 6;
		#5;
		round = 7;
		#5;
		round = 8;
		#5;
		round = 9;
		#5;
		round = 10;
		#5;
		$stop;
	end
endmodule 