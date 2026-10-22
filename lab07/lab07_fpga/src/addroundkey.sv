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