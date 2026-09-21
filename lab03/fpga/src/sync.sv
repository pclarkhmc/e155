module sync (
    input  logic clk,       
    input  logic d_in,     
    output logic q_out
);

    logic n1;

    always_ff @(posedge clk) begin
            n1 <= d_in;
            q_out <= n1;
        end
   
endmodule
