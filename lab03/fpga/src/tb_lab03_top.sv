`timescale 1ms / 1ms

module tb_lab03_top();
	
	
	logic enable_in, reset_in;
	logic [3:0] cols_in, rows;
	logic [6:0] display;
	logic [1:0] seg_power;
	
	lab03_top #(6) 
		dut(.enable_in(enable_in), .reset_in(reset_in), .cols_in(cols_in), .rows(rows), .display(display),.seg_power(seg_power));
	
	
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
		#50;
		cols_in = 4'b1111;
		#50;
		
		cols_in = 4'b1101;
		#50;
		cols_in = 4'b1111;
		#50;
		
		cols_in = 4'b1011;
		#50;
		cols_in = 4'b1111;
		#50;
		
		cols_in = 4'b0111;
		#50;
		cols_in = 4'b1111;
		#50;
		
		// reset
		reset_in = 0;
		#20;
		reset_in = 1;
		#20;
		
		// walk two bits
		cols_in = 4'b1100;
		#50;
		cols_in = 4'b1111;
		#50;
		
		cols_in = 4'b1001;
		#50;
		cols_in = 4'b1111;
		#50;
		
		cols_in = 4'b0011;
		#50;
		cols_in = 4'b1111;
		#50;
		#100;
		$stop;
	end
	
	
endmodule