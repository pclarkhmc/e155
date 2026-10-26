module cipher_core(
		input logic clk, en, reset,
		input logic [1:0] sel,
		input logic [127:0] plaintext,
		input logic [127:0] key_in,
		output logic [127:0] cyphertext,
		output logic done
		);

	logic [127:0] s1, s2, s3, s4, s5;
	
	// State register
	flopen #(128) Reg1(.clk(clk), .en(en), .d(s5), .q(s1));
	
	//subbyte
	subbyte subbyte1(.clk(clk), .reset(reset), .done(done),.a(s1),.y(s2));
	
	//shift
	shiftrows shiftrows1(.a(s2),.y(s3));

	//mixcols
	mixcolumns mixcolumns(.a(s3),.y(s4));
	
	// Mux
	mux3 #(128) mux3 (.d0(plaintext), .d1(s3), .d2(s4), .s(sel), .y());
	
	// add round key
	addroundkey addroundkey(.a(), .key(key_in), .y(s5));

endmodule
