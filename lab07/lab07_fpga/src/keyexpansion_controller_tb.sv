module keyexpansion_controller_tb();

	logic clk, reset;
	logic [3:0] round;
	logic [127:0] key_in, key_out;
	logic key_ready;
	keyexpansion_controller DUT(.clk(clk), .reset(reset), .round(round),.key_in(key_in),.key_out(key_out),.key_ready(key_ready));
	
	always begin
		clk = 1; #2;
		clk = 0; #2;
	end
	
	
	initial begin
		#2;		
		round = 0;
		key_in = 128'h2B7E151628AED2A6ABF7158809CF4F3C;
		reset = 1;
		#8;
		reset = 0;
		
		#40;
		
		round = 1;	// A0FAFE1788542CB123A339392A6C7605
		#40;
		
		round = 2;	// F2C295F27A96B9435935807A7359F67F
		#40;
		
		round = 3;	// 3D80477D4716FE3E1E237E446D7A883B
		#40;
		
		round = 4;	// EF44A541A8525B7FB671253BDB0BAD00
		#40;
		
		round = 5;	// D4D1C6F87C839D87CAF2B8BC11F915BC
		#40;
		
		round = 6;	// 6D88A37A110B3EFDDBF98641CA0093FD
		#40;
		
		round = 7;	// 4E54F70E5F5FC9F384A64FB24EA6DC4F
		#40;
		
		round = 8;	// EAD27321B58DBAD2312BF5607F8D292F
		#40;
		
		round = 9;	// AC7766F319FADC2128D12941575C006E
		#40;
		
		round = 10;	// D014F9A8C9EE2589E13F0CC8B6630CA6
		#40;
		$stop;
	end
endmodule
