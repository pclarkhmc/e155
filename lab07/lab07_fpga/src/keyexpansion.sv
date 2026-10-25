
/////////////////////////////////////////////
// keyexpansion
//   routine used to generate 4*(Nr+1) words
//  
/////////////////////////////////////////////

module keyexpansion(
	input logic [127:0] oldkey,
	input logic [3:0] round,
	output logic [127:0] newkey
	);
	
	logic [31:0] n1,n2,n3,rcon;
	rotword rot1(.a(oldkey[31:0]), .y(n1));
	subword sub1(.a(n1), .y(n2));
	rcon	rcon1(.j(round), .y(rcon));
	assign n3 = n2 ^ rcon;
	
	assign newkey[127:96] = oldkey[127:96] ^ (n3);
	assign newkey[95:64] = newkey[127:96] ^ oldkey[95:64];
	assign newkey[63:32] = newkey[95:64] ^ oldkey[63:32];
	assign newkey[31:0] = newkey[63:32] ^ oldkey[31:0];
	
endmodule
