module keypad_decoder(
	input logic [3:0] cols, rows,
	output logic [3:0] key
	);
	
	always_comb begin
		if (rows[0]) begin
			if (cols[0])      key = 4'h1;
			else if (cols[1]) key = 4'h2;					
			else if (cols[2]) key = 4'h3;
			else              key = 4'hA;
		end
		else if (rows[1]) begin
			if (cols[0])      key = 4'h4;
			else if (cols[1]) key = 4'h5;					
			else if (cols[2]) key = 4'h6;
			else              key = 4'hB;
		end
		else if (rows[2]) begin
			if (cols[0])      key = 4'h7;
			else if (cols[1]) key = 4'h8;					
			else if (cols[2]) key = 4'h9;
			else              key = 4'hC;
		end
		else begin
			if (cols[0])      key = 4'hE;
			else if (cols[1]) key = 4'h0;					
			else if (cols[2]) key = 4'hF;
			else              key = 4'hD;
		end
	end
endmodule
