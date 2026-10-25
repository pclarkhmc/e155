module subword(
	input logic clk, reset,
	input logic [31:0] a,
	output logic [31:0] y,
	output logic done
	);
	
	logic [2:0] count;
	logic [7:0] s_in, s_out;
	logic en;
	
	always_ff @(posedge clk) begin
		if (reset) begin
		count <= 0;
		en <= 1'b1;
		done <= 0;
		end
		else begin
			if (count != 3'b100) 
				count <= count + 1;
			else begin
				en <= 0;
				done <= 1;
			end
		end	
	end
	
	// feed in bytes one at a time
	mux4 mux4(.d0(a[7:0]), .d1(a[15:8]), .d2(a[23:16]), .d3(a[31:24]), .sel(count[1:0]), .y(s_in));
	sbox_sync sbox(.clk(clk), .a(s_in), .y(s_out));

	// shift result into register
	shift_reg #(8,4) shift_reg_subbyte(.clk(clk), .reset(reset), .en(en), .data_in(s_out), .data_out(y));

endmodule