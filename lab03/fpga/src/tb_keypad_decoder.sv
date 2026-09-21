`timescale 1 ns/1 ns


module tb_keypad_decoder();

	logic [3:0] cols, rows, key;
	keypad_decoder dut (.cols(cols), .rows(rows), .key(key));
	
	
	initial begin
		rows = 0;
		cols = 0;
		#5;
		//scan through row 1
		rows = 1;
		cols = 1;
		#5;
		cols = 2;
		#5;
		cols = 4;
		#5;
		cols = 8;
		#5;
		//scan through row 2
		rows = 2;
		cols = 1;
		#5;
		cols = 2;
		#5;
		cols = 4;
		#5;
		cols = 8;
		#5;
		//scan through row 3
		rows = 4;
		cols = 1;
		#5;
		cols = 2;
		#5;
		cols = 4;
		#5;
		cols = 8;
		#5;
		//scan through row 4
		rows = 8;
		cols = 1;
		#5;
		cols = 2;
		#5;
		cols = 4;
		#5;
		cols = 8;
		#5;
		
		$stop;
	end
	
endmodule