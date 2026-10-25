module shift_reg #(
    parameter WIDTH = 8,
    parameter DEPTH = 4
)(
    input clk,
    input reset,
    input en,
    input [WIDTH - 1:0] data_in,
    output [WIDTH*DEPTH - 1 : 0] data_out
);
     
    // internal signals
    logic [WIDTH*DEPTH - 1 : 0] ShiftReg;
    
    always @(posedge clk) begin
        if (reset) begin
            ShiftReg <= '0;
        end else if (en) begin 
            ShiftReg <= {data_in, ShiftReg[WIDTH*DEPTH-1 : WIDTH]};
        end
    end
             
    assign data_out = ShiftReg;
                           
endmodule
