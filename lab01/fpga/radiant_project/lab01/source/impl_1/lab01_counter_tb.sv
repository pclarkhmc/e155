`timescale 1 ns/1 ns

module lab01_tb();
	logic           clk;    // system clock
	logic           reset;  // active high reset
	logic			  enable; // clock enable
	logic   [31:0]  count;
 
	counter dut_counter(clk,reset,enable,led,count);
  
	initial begin    
		// test 2
		// test that enable stops the counter
		enable = 1;
        countintial <= count;
        #10;
        assert (count == countintial)
            $display("PASSED! The count did not increment when enable = 1: %0t.", $time);
        else 
            $error("FAILED! The count changed when enable = 1: %0t.", $time);
			
		// test 3
		// test reset sets the counter = 0
		reset = 1;
		enable = 0;
		assert (count == 0)
            $display("PASSED! The count reset to zero at time: %0t.", $time);
        else 
            $error("FAILED! The count did NOT reset to zero at time: %0t.", $time);
	end
  
endmodule