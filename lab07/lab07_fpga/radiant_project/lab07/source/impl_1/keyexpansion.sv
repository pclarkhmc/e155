
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
	
	assign newkey[127:96] = newkey[127:96] ^ (n3);
	assign newkey[95:64] = newkey[127:96] ^ oldkey[95:64];
	assign newkey[63:32] = newkey[95:64] ^ oldkey[63:32];
	assign newkey[31:0] = newkey[63:32] ^ oldkey[31:0];
	
endmodule

module rotword(
	input logic [31:0] a,
	output logic [31:0] y
	);
	assign y = {a[23:16],a[15:8],a[7:0],a[31:27]};
endmodule


module subword(
	input logic [31:0] a,
	output logic [31:0] y
	);
	sbox sbox0(a[7:0],y[7:0]);
	sbox sbox1(a[15:8],y[15:8]);
	sbox sbox2(a[23:16],y[23:16]);
	sbox sbox3(a[31:24],y[31:24]);
	
endmodule

/////////////////////////////////////////////
// sbox
//   Infamous AES byte substitutions with magic numbers
//   Combinational version which is mapped to LUTs (logic cells)
//   Section 5.1.1, Figure 7
/////////////////////////////////////////////

module sbox(input  logic [7:0] a,
            output logic [7:0] y);
            
  // sbox implemented as a ROM
  // This module is combinational and will be inferred using LUTs (logic cells)
  logic [7:0] sbox[0:255];

  initial   $readmemh("sbox.txt", sbox);
  assign y = sbox[a];
endmodule

module rcon(
	input logic [3:0] j,
	output logic [31:0] y
	);
	always_comb begin
		case (j) 
			1 : y = 32'h01000000;
			2 : y = 32'h02000000;
			3 : y = 32'h04000000;
			4 : y = 32'h08000000;
			5 : y = 32'h10000000;
			6 : y = 32'h20000000;
			7 : y = 32'h40000000;
			8 : y = 32'h80000000;
			9 : y = 32'h1b000000;
			10 : y = 32'h36000000;
			default: y = 32'h00000000; // Catch-all condition
		endcase
	end
endmodule