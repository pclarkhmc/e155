`timescale 1 ns/1 ns

module lab01_counter_tb();
  logic clk, reset, enable, led;
  counter #(32, 10)
		dut(.clk(clk), .reset(reset), .enable(enable), .led(led));
  always begin
	  clk = 0; #5;
	  clk = 1; #5;
  end
  
  initial begin
	  reset = 1;
	  enable = 1;
	  #10 reset = 0;
	  #180 reset = 1;
	  #10 reset = 0;
	  #90 enable = 0;
	  #100;
  end
endmodule