module cipher_core(
		input logic 			clk,
		input logic 			advance,	// new round	
		input logic [3:0] 		round,
		input logic [127:0] 	plaintext,
		input logic [127:0] 	key_in,
		output logic [127:0] 	cyphertext,
		output logic 			done
		);

	logic [127:0] s1, s2, s3, s4, s5, s6;
	logic [1:0] sel;
	// Per round logic / sel signal
	always_comb begin
		if (round == 0)
			begin
				sel = 0; // input key_in
			end
		else if (round == 10) 
			begin
				sel = 1; // skip stage
			end
		else  
			begin
				sel = 2; // round 1-9
			end
	end
	
	// State register
	flopen #(128) reg1(.clk(clk), .en(advance), .d(s6), .q(s1));
	
	//subbyte
	subbyte subbyte1(.clk(clk), .reset(advance), .done(done),.a(s1),.y(s2));
	
	//shift
	shiftrows shiftrows1(.a(s2),.y(s3));

	//mixcols
	mixcolumns mixcolumns(.a(s3),.y(s4));
	
	// Mux
	mux3 #(128) mux3 (.d0(plaintext), .d1(s3), .d2(s4), .s(sel), .y(s5));
	
	// add round key
	addroundkey addroundkey(.a(s5), .key(key_in), .y(s6));
	
	assign cyphertext = s6;

endmodule
