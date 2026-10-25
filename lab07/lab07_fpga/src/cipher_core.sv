module cipher_core#(
		parameter Nr = 10
)(
		input clk,
		input logic [127:0] data,
		input logic [127:0] key);


	
	
	logic [127:0] s1, s2, s3, s4, s5;
	logic reset, done;
	
	// State register
	flopen #(128) Reg1(.clk(clk), .en(), .d(), .q());
	
	//subbyte
	subbyte subbyte1(.clk(clk), .reset(reset), .done(done),.a(s1),.y(s2));
	
	//shift
	shiftrows shiftrows1(.a(s2),.y(s3));

	//mixcols
	mixcolumns mixcolumns(.a(s3),.y(s4));
	
	// Mux
	mux3 #(128) mux3 (.d0(data), .d1(s3), .d2(s4), .s(), .y());
	
	// add round key
	addroundkey addroundkey(.a(), .key(key), .y(s5));

endmodule
