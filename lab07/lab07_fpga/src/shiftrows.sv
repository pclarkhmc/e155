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
