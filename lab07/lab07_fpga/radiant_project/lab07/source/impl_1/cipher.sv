
module cipher_controller();
	
	
endmodule

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

/////////////////////////////////////////////
// sbox
//   Infamous AES byte substitutions with magic numbers
//   Synchronous version which is mapped to embedded block RAMs (EBR)
//   Section 5.1.1, Figure 7
/////////////////////////////////////////////
module sbox_sync(
	input		logic [7:0] a,
	input	 	logic 			clk,
	output 	logic [7:0] y);
            
  // sbox implemented as a ROM
  // This module is synchronous and will be inferred using BRAMs (Block RAMs)
  logic [7:0] sbox [0:255];

  initial   $readmemh("sbox.txt", sbox);
	
	// Synchronous version
	always_ff @(posedge clk) begin
		y <= sbox[a];
	end
endmodule

/////////////////////////////////////////////
// shiftrows
//   Shift Rows of array
//   Section 5.1.2, Figure 3
/////////////////////////////////////////////

module shiftrows(input 	logic [127:0] a,
				 output	logic [127:0] y);
		
		assign y[127:96] 	= {a[127:120],	a[87:80],	a[47:40],	a[7:0]};
		assign y[95:64] 	= {a[95:88],	a[55:48],	a[15:8],	a[103:96]};
		assign y[63:32] 	= {a[63:56],	a[23:16],	a[111:104],	a[71:64]};
		assign y[31:0] 		= {a[31:24],	a[119:112],	a[79:72],	a[39:32]};
	
endmodule

/////////////////////////////////////////////
// mixcolumns
//   Even funkier action on columns
//   Section 5.1.3, Figure 9
//   Same operation performed on each of four columns
/////////////////////////////////////////////

module mixcolumns(input  logic [127:0] a,
                  output logic [127:0] y);

  mixcolumn mc0(a[127:96], y[127:96]);
  mixcolumn mc1(a[95:64],  y[95:64]);
  mixcolumn mc2(a[63:32],  y[63:32]);
  mixcolumn mc3(a[31:0],   y[31:0]);
endmodule

/////////////////////////////////////////////
// mixcolumn
//   Perform Galois field operations on bytes in a column
//   See EQ(4) from E. Ahmed et al, Lightweight Mix Columns Implementation for AES, AIC09
//   for this hardware implementation
/////////////////////////////////////////////

module mixcolumn(input  logic [31:0] a,
                 output logic [31:0] y);
                      
        logic [7:0] a0, a1, a2, a3, y0, y1, y2, y3, t0, t1, t2, t3, tmp;
        
        assign {a0, a1, a2, a3} = a;
        assign tmp = a0 ^ a1 ^ a2 ^ a3;
    
        galoismult gm0(a0^a1, t0);
        galoismult gm1(a1^a2, t1);
        galoismult gm2(a2^a3, t2);
        galoismult gm3(a3^a0, t3);
        
        assign y0 = a0 ^ tmp ^ t0;
        assign y1 = a1 ^ tmp ^ t1;
        assign y2 = a2 ^ tmp ^ t2;
        assign y3 = a3 ^ tmp ^ t3;
        assign y = {y0, y1, y2, y3};    
endmodule

/////////////////////////////////////////////
// galoismult
//   Multiply by x in GF(2^8) is a left shift
//   followed by an XOR if the result overflows
//   Uses irreducible polynomial x^8+x^4+x^3+x+1 = 00011011
/////////////////////////////////////////////

module galoismult(input  logic [7:0] a,
                  output logic [7:0] y);

    logic [7:0] ashift;
    
    assign ashift = {a[6:0], 1'b0};
    assign y = a[7] ? (ashift ^ 8'b00011011) : ashift;
endmodule


/////////////////////////////////////////////
// addroundkey
//   Multiply by x in GF(2^8) is a left shift
//   followed by an XOR if the result overflows
//   Uses irreducible polynomial x^8+x^4+x^3+x+1 = 00011011
/////////////////////////////////////////////

module addroundkey(input logic [127:0] a,
					input logic [127:0] key,
					output logic [127:0] y);
		assign y = a ^ key;

endmodule