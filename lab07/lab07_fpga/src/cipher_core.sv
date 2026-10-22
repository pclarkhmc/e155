module cipher_core#(
		parameter Nr = 10
)(
		input clk,
		input logic [127:0] in,
		input logic [127:0] key);


	// State register
	flopen #(32) Reg1(.clk(clk), .en(), .d(), .q());
	
	//subbyte
	sbox_sync sbox_sync1(.a(),.clk(),.y());
	
	//shift
	shiftrows shiftrows1(.a(),.y());

	//mixcols
	mixcolumns mixcolumns(.a(),.y());
	
	// Mux
	mux3 #(31) mux3 (.d0(), .d1(), .d2(), .s(), .y());
	
	//Addr
    galoismult galoismult(.a(),.y());


endmodule
