module synchronizer (
    input  logic clk,       
    input  logic reset,    
    input  logic d_in,     
    output logic q_out
);

    logic stage1;
    logic stage2;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            stage1 <= 1'b0;
            stage2 <= 1'b0;
        end else begin
            stage1 <= d_in;
            stage2 <= stage1;
        end
    end

    assign q_out = stage2;

endmodule
