module debouncer(
    input logic sw,
	input logic clk, reset,
	output logic debounced_sw
	);
	typedef enum logic [1:0] {IDLE, WAIT, PRESSED} statetype;
	statetype state, nextstate;
	logic [19:0] counter;
	
	always_ff @(posedge clk, posedge reset)
		if (reset) state <= IDLE;
		else state <= nextstate;

	// The FSM owns the counter: cleared in IDLE, running everywhere else.
	always_ff @(posedge clk)
		if (state == IDLE) counter <= 0;
		else counter <= counter + 1;
			
    always_comb
		case (state)
			IDLE: nextstate = sw ? WAIT : IDLE;
			WAIT: if (!sw) nextstate = IDLE; // a bounce
				else if (counter[19]) nextstate = PRESSED;
				else nextstate = WAIT;
			PRESSED: nextstate = sw ? PRESSED : IDLE;
			default: nextstate = IDLE;
 		endcase

	assign debounced_sw = (state == PRESSED);
endmodule