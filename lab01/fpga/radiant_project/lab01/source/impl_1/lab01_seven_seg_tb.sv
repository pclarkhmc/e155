`timescale 1 ns/1 ns

module lab01_seven_seg_tb();
  logic   [3:0]   s;      // 4-bit input switches
  logic   [6:0]	  seg; 	  // 7-seg display
	
  
  seven_seg dut (.switches(s), .seg(seg));
  //apply stimuli and check inputs
  initial begin 
	for (int i=0; i<16; i++) begin
	s = i;
	#10;
	end 
  end	
endmodule