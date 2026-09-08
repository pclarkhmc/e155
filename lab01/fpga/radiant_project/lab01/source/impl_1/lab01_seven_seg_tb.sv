`timescale 1 ns/1 ns

module lab01_tb();
  logic   [3:0]   s;      // 4-bit input switches
  logic   [6:0]	  seg; 	  // 7-seg display
  
  seven_seg dut (switches, seg);
  initial begin
	  for (i=0; i<16; i++)
		  oldseg = seg
		  switches = i;
		  #10;
		  assert (old_seg != seg); // assert each value is unique
	  end
endmodule