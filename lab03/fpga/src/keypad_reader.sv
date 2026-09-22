module keypad_reader(
	input logic [3:0] cols,
	input logic [3:0] key,
	input logic clk, reset,
	output logic scan,
	output logic [3:0] d0, d1
	);
	
	typedef enum logic [2:0] {SCAN = 3'b001, PRESS = 3'b010, HOLD = 3'b100} statetype;
	statetype state, nextstate;
	logic any_key;

	assign any_key = |cols; // low-asserted: any column pulled down

	// reset logic
	always_ff @(posedge clk, posedge reset)
		if (reset) state <= SCAN;
		else state <= nextstate;

	// next state logic
	always_comb
		case (state)
			SCAN: nextstate = any_key ? PRESS : SCAN;
			PRESS: nextstate = HOLD;
			HOLD: nextstate = any_key ? HOLD : SCAN;
			default: nextstate = SCAN;
		endcase
	
	// scan / display logic
	always_ff @(posedge clk, posedge reset)
		if (reset) begin
			scan <= 1'b0;
			d0 <= 4'h0;
			d1 <= 4'h0;
		end else begin
			// Only SCAN moves the row pattern. Everything else freezes it.
			if (state == SCAN && !any_key) scan <= 1;
			else scan <= 0;
			if (state == PRESS) begin
				d1 <= d0;
				d0 <= key; // take current key
			end
		end
		// if (state == hold) & (key != oldkey) & onekey

endmodule

 




