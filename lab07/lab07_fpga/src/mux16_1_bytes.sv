module mux16_bytes (
    input  logic [127:0] a, 
    input  logic [  3:0] s,  // 4-bit select line
    output logic [  7:0] y   // 1 selected byte output
);

    assign y = a >> (s * 8);

endmodule