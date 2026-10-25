module subbyte(
	input logic clk, reset,
	input logic [127:0] a,
	output	logic [127:0] y,
	output logic done //signal when done
	);
	
		
	logic [4:0] count;
	logic [7:0] s_in, s_out;
	logic en;
	
	always_ff @(posedge clk) begin
		if (reset) begin
		count <= 0;
		en <= 1'b1;
		done <= 0;
		end
		else begin
			if (count != 5'b10000) 
				count <= count + 1;
			else begin
				en <= 0;
				done <= 1;
			end
		end	
	end
	
	mux16_bytes mux16_bytes(.a(a), .s(count[3:0]), .y(s_in));
	sbox_sync sbox(.clk(clk), .a(s_in), .y(s_out));
	
	// shift reg of width 8, and length 16
	shift_reg #(8,16) shift_reg_subbyte(.clk(clk), .reset(reset), .en(en), .data_in(s_out), .data_out(y));

endmodule