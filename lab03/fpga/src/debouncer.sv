module debouncer#(
	parameter int wait_time = 20000000
)(
    input logic d_in,
    output logic q_out,
    output logic [3:0] row_clean,
    output logic [3:0] col_clean
);


    logic reset_count; // internal reset signal
    always_ff(posedge d_in)
        
    counter #(32, 480000)
		counter1(.clk(int_clk), .reset(reset), .enable(enable), .count(counter));
    assign q_out = (count > 0)
endmodule