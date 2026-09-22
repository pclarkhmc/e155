module tb_display();

	logic clk, enable, reset;
	logic [7:0] data;
	logic [6:0] display;
	logic [1:0] seg_power;
	display dut (.clk(clk), .enable(enable), .reset(reset),.data(data),.display(display),.seg_power(seg_power));

	always begin
		clk = 0; #5;
		clk = 1; #5;
	end

	initial begin
		enable = 1;
		reset = 0;
		data = 0;
		// bump reset
		reset = 1;
		#10;
		reset = 0;
		#10;
		
		
		for (int i = 0; i<16; i++) begin
			data[3:0] = i;
			#10;
		end
		data = 0;
		#10;
		for (int i = 0; i<16; i++) begin
			data[7:4] = i;
			#10;
		end
		
	end

endmodule