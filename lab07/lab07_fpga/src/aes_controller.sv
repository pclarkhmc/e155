module aes_controller(
	input  logic         clk, 
	input  logic         load,
	input  logic cypher_done, key_ready,
	
	output logic start, advance,
	output logic [3:0] round,
	output logic done
	);

	// track load
	logic old_load;
	logic en;
	
	// control signals
	assign start = old_load & ~load; // falling edge of load
	assign en = cypher_done && (round != 0) && (round < 10); // increase round when done

	always_ff @(posedge clk) begin
		// track load
		old_load <= load;

		// round logic
		if (load)
			begin
				round <= 0;
			end
		else if (start)
			begin
				round <= 1;
			end
		else if (en) begin
				round <= round + 1;
			end
			
		// done logic
		if ((round == 10) && cypher_done && key_ready) done <= 1;
		else done <= 0;
		
	end
	
	assign advance = (en | start);
	
endmodule