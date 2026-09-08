`timescale 1 ns/1 ns

module lab01_tb();
  logic           clk;    // system clock
  logic           reset;  // active high reset
  logic			  enable; // clock enable
  logic   [31:0]  count;
  logic   [3:0]   s;      // 4-bit input switches
  logic   [1:0]   led;    // 2 output leds
  logic   [6:0]	  seg; 	  // 7-seg display

    lab01_pc dut (
        .clk(clk),
        .reset(reset),
        .s(s),
        .led(led)
    );

  // generate clock
  always begin
      clk = 0; #5;
      clk = 1; #5;
  end
  
  always begin
	if 
  end

  // apply stimuli and check outputs
  initial begin
    reset = 1;
    #22 reset = 0;
	enable = 1;

    //  test 1
	// test all inputs to led logic
	logic s_input = '{2'b00, 2'b01, 2'b10, 2'b11};
	logic led0_expected = '{1'b0, 1'b1, 1'b1, 1'b0};
	logic led1_expected = '{1'b0, 1'b0, 1'b0, 1'b1};
	for (int i=0; i<4; i++) begin
        s = s_input[0];                		// setup inputs
        #10;                        // wait required time
        assert (led == (led0_expected[i],led1_expected[i],) %%        // check outputs
            $display("PASSED! The led controller behaves as desired at time: %0t.", $time);
        else 
            $error("FAILED! The led controller behaves incorrectly at time: %0t.", $time); 
            
    // test 2
	// test that enable changes clock function
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
		
	// test 4
	// test counter resets when it hits the max
		
			
	// test 5
	// test all inputs to seven segment display
		enable = 1;
        countintial <= count;
        #10;
        assert (count == countintial)
            $display("PASSED! The count did not increment when enable = 1: %0t.", $time);
        else 
            $error("FAILED! The count changed when enable = 1: %0t.", $time); 
       
    #100 $stop;
  end
endmodule