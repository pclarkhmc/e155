module mux16_bytes (
    input  wire [127:0] a,  // 16 bytes flattened (16 * 8 bits = 128 bits)
    input  wire [  3:0] s,  // 4-bit select line
    output wire [  7:0] y   // 1 selected byte output
);

    assign y = a[s * 8 +: 8];

endmodule