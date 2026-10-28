/////////////////////////////////////////////
// tb_ai_keyexpansion
//   checks both AI prototypes against the full
//   key schedule in FIPS-197 Appendix A.1
/////////////////////////////////////////////

module tb_ai_keyexpansion();
	// FIPS-197 A.1 expanded key, w[0]..w[43]
	localparam logic [44*32-1:0] EXPECTED = {
		32'h2b7e1516, 32'h28aed2a6, 32'habf71588, 32'h09cf4f3c,
		32'ha0fafe17, 32'h88542cb1, 32'h23a33939, 32'h2a6c7605,
		32'hf2c295f2, 32'h7a96b943, 32'h5935807a, 32'h7359f67f,
		32'h3d80477d, 32'h4716fe3e, 32'h1e237e44, 32'h6d7a883b,
		32'hef44a541, 32'ha8525b7f, 32'hb671253b, 32'hdb0bad00,
		32'hd4d1c6f8, 32'h7c839d87, 32'hcaf2b8bc, 32'h11f915bc,
		32'h6d88a37a, 32'h110b3efd, 32'hdbf98641, 32'hca0093fd,
		32'h4e54f70e, 32'h5f5fc9f3, 32'h84a64fb2, 32'h4ea6dc4f,
		32'head27321, 32'hb58dbad2, 32'h312bf560, 32'h7f8d292f,
		32'hac7766f3, 32'h19fadc21, 32'h28d12941, 32'h575c006e,
		32'hd014f9a8, 32'hc9ee2589, 32'he13f0cc8, 32'hb6630ca6};

	// Prompt 1: one round at a time
	logic [127:0] prev_key, next_key;
	logic [3:0]   round;
	keyexpansion dut1(.prev_key(prev_key), .round(round), .next_key(next_key));

	// Prompt 2: whole schedule at once
	logic [7:0]  key  [0:15];
	localparam logic [11*32-1:0] RCON = {32'h00000000, 32'h01000000, 32'h02000000, 32'h04000000,
	                                      32'h08000000, 32'h10000000, 32'h20000000, 32'h40000000,
	                                      32'h80000000, 32'h1b000000, 32'h36000000};
	logic [31:0] rcon [0:10];
	logic [31:0] expected [0:43];
	logic [31:0] w    [0:43];
	word_expand dut2(.key(key), .rcon(rcon), .w(w));

	int errors1 = 0, errors2 = 0;

	initial begin
		for (int j = 0; j <= 10; j++) rcon[j] = RCON[32*(10-j) +: 32];
		for (int j = 0; j <= 43; j++) expected[j] = EXPECTED[32*(43-j) +: 32];

		// Prompt 1: chain next_key back into prev_key for rounds 1..10
		prev_key = {expected[0], expected[1], expected[2], expected[3]};
		for (int r = 1; r <= 10; r++) begin
			round = r;
			#1;
			if (next_key !== {expected[4*r], expected[4*r+1], expected[4*r+2], expected[4*r+3]}) begin
				$display("Prompt 1 round %0d: got %h", r, next_key);
				errors1++;
			end
			prev_key = next_key;
		end
		$display("Prompt 1 (with spec):    %0d/10 round keys correct", 10 - errors1);

		// Prompt 2: load the cipher key bytes and check every word
		for (int b = 0; b < 16; b++) key[b] = expected[b/4][31-8*(b%4) -: 8];
		#1;
		// read dut2.w directly: iverilog 12 does not drive unpacked-array output ports
		for (int i = 0; i < 44; i++)
			if (dut2.w[i] !== expected[i]) begin
				$display("Prompt 2 w[%0d]: got %h, expected %h", i, dut2.w[i], expected[i]);
				errors2++;
			end
		$display("Prompt 2 (without spec): %0d/44 words correct", 44 - errors2);
		$finish;
	end
endmodule
