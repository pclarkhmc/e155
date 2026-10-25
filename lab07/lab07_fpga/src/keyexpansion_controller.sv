module keyexpansion_controller(
	input logic clk, en, reset,
	input logic [3:0] round,
	input logic [127:0] key_in,
	output logic [127:0] key_out
	);
	
	// register round and key
	//logic [3:0] old_round;
	//flopenr #(4) round_reg(.clk(clk), .en(en), .reset(reset), .d(round), .q(old_round));
	logic [127:0] old_key, new_key;
	flopenr #(128) key_reg(.clk(clk), .en(en), .reset(), .d(key_out), .q(old_key));

	// generate new key
	logic reset_key_ex;
	keyexpansion keyexpansion1(.clk(clk), .reset(reset_key_ex), .oldkey(old_key), .round(round), .newkey(new_key));
	
	// output mux
	always_comb begin
		if (round == 0)	key_out = key_in;
		else key_out = new_key;
		if (key_out != old_key) reset_key_ex <= 1;
		else reset_key_ex <= 0;
	end

endmodule
