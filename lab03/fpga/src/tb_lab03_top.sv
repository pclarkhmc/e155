`timescale 1ms / 1ms

module tb_lab03_top();
	
	
	logic enable_in, reset_in;
	logic [3:0] cols_in, rows;
	logic [6:0] display;
	logic [1:0] seg_power;
	
	lab03_top #(6) 
		dut(.reset_in(reset_in), .cols_in(cols_in), .rows(rows), .display(display),.seg_power(seg_power));
	
	
	initial begin		
		// initial
		enable_in = 0;
		reset_in = 1;
		cols_in = 4'b1111;
		
		// bump reset
		reset_in = 0;
		#10;
		reset_in = 1;
		#10;
		
		cols_in = 4'b1111;
		#10; 
		
		// walk one bit
		cols_in = 4'b1110;
		#10;
		cols_in = 4'b1111;
		#10;
		
		cols_in = 4'b0111;
		#10;
		cols_in = 4'b1111;
		#10;
		
		cols_in = 4'b1011;
		#10;
		cols_in = 4'b1111;
		#10;
		
		// reset
		reset_in = 0;
		#10;
		reset_in = 1;
		#10;
		
		// continue
		cols_in = 4'b1011;
		#10;
		cols_in = 4'b1111;
		#10;
		
		cols_in = 4'b0111;
		#10;
		cols_in = 4'b1111;
		#10;
		$stop;
	end
	
	
endmodule