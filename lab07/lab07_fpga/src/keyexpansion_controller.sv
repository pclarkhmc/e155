module keyexpansion_controller(
	input logic clk, reset,
	input logic [3:0] round,
	input logic [127:0] key_in,
	output logic [127:0] key_out,
	output logic key_ready
	);
	
	// detect a new round
	logic [3:0] old_round;
	logic start, done;
	always_ff @(posedge clk)
		if (reset) old_round <= 4'hF;	// forces a start after reset
		else old_round <= round;
	assign start = (round != old_round);
	
	// generate new key from the held key
	logic [127:0] new_key;
	keyexpansion keyexpansion1(.clk(clk), .reset(start | reset), .oldkey(key_out), .round(round), .newkey(new_key), .done(done));
	
	// load key once per round
	always_ff @(posedge clk)
		// on reset, key not ready
		if (reset) key_ready <= 0;
		else if (round == 0) begin
			key_out <= key_in; // feed in initial key
			key_ready <= 1;
		end
		// on round change, reset key
		else if (start) key_ready <= 0;
		else if (done && !key_ready) begin
			key_out <= new_key;
			key_ready <= 1;
		end

endmodule
