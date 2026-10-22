module subword(
	input logic [31:0] a,
	output logic [31:0] y
	);
	sbox sbox0(a[7:0],y[7:0]);
	sbox sbox1(a[15:8],y[15:8]);
	sbox sbox2(a[23:16],y[23:16]);
	sbox sbox3(a[31:24],y[31:24]);
	
endmodule
