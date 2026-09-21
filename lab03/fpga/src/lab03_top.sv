module lab03_top#(
	parameter int flip_bit = 17
)(
	// control
	input logic enable_in, reset_in,
	// keypad in/out
	input logic [3:0] cols_in,
	output logic [3:0] rows,
	// display data and mux
	output logic [6:0] display,
	output logic [1:0] seg_power
	
);
	// declare an internal clock of 48 Mhz
	logic int_clk;
	HSOSC #(.CLKHF_DIV(2'b00))
		 hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_clk));
		 
		 
	///////////////////////////// Synch and Debounce inputs
	
	// Active low, flip signal
	logic [3:0] cols_unsync;
	logic enable_unsync, reset_unsync;
	assign cols_unsync = ~ cols_in;
	assign enable_unsync = 1'b1;
	assign reset_unsync = ~reset_in;

	
	// sync all inputs
	logic [3:0] cols;
	logic enable, reset;
	sync sync_reset (.clk(int_clk), .d_in(reset_unsync), .q_out(reset));
	sync sync_enable (.clk(int_clk), .d_in(enable_unsync), .q_out(enable));
	genvar i; 
	generate
        for (i = 0; i < 4; i = i + 1) begin : sync_gen
            sync sync_inst (
                .clk(int_clk),
				.d_in(cols_unsync[i]),
				.q_out(cols[i])
            );
        end
    endgenerate
	
	// debounce all columns
	logic [3:0] cols_debounce;
	generate
        for (i = 0; i < 4; i = i + 1) begin : debounce_gen
            debouncer #(flip_bit) debounce_inst (
				.sw(cols[i]),
                .clk(int_clk),
				.reset(reset),
				.debounced_sw(cols_debounce[i])
            );
        end
    endgenerate


	// keypad scanner:
	logic scan;
	logic [3:0] row_sel;
	scanner #(32, 6000000)
		scanner1 (.clk(int_clk), .enable(scan), .reset(reset), .scan(row_sel));
	assign rows = ~row_sel;

	// decode to get key
	logic [3:0] key;
	keypad_decoder keypad_decoder1 (.cols(cols_debounce), .rows(row_sel), .key(key));
	
	// determine when to send
	logic [3:0] d0, d1;
	keypad_reader keypad_reader1 (.cols(cols_debounce), .key(key), .clk(int_clk), .reset(reset), .scan(scan), .d0(d0), .d1(d1));

	// display
	display display_logic(.clk(int_clk), .enable(enable), .reset(reset),.data({d0, d1}),.display(display),.seg_power(seg_power));
	

endmodule