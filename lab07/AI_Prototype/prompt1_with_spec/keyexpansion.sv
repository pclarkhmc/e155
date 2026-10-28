// keyexpansion.sv
// Combinational AES-128 key expansion step (FIPS-197 Sec. 5.2, Alg. 2, Fig. 6).
// Given round key (round-1), produce round key (round).
//   round = 1  : prev_key is the cipher key, next_key is round key 1
//   round = 10 : next_key is the final round key
module keyexpansion (
    input  logic [127:0] prev_key,   // {w[4r-4], w[4r-3], w[4r-2], w[4r-1]}
    input  logic [3:0]   round,      // r, the round whose key is being generated (1..10)
    output logic [127:0] next_key    // {w[4r],   w[4r+1], w[4r+2], w[4r+3]}
);

    // Split the previous round key into its four 32-bit words.
    // Word 0 is the most significant (holds key bytes 0..3), per Sec. 3.
    logic [31:0] w0, w1, w2, w3;
    assign {w0, w1, w2, w3} = prev_key;

    // temp <- SubWord(RotWord(w[i-1])) xor Rcon[i/Nk]   (Alg. 2, line 10)
    logic [31:0] rotated, substituted, rcon, temp;

    rotword u_rotword (.a(w3),      .y(rotated));
    subword u_subword (.a(rotated), .y(substituted));

    // Round constants, Table 5: Rcon[j] = [x^(j-1), 00, 00, 00]
    always_comb begin
        case (round)
            4'd1:    rcon = 32'h01_00_00_00;
            4'd2:    rcon = 32'h02_00_00_00;
            4'd3:    rcon = 32'h04_00_00_00;
            4'd4:    rcon = 32'h08_00_00_00;
            4'd5:    rcon = 32'h10_00_00_00;
            4'd6:    rcon = 32'h20_00_00_00;
            4'd7:    rcon = 32'h40_00_00_00;
            4'd8:    rcon = 32'h80_00_00_00;
            4'd9:    rcon = 32'h1b_00_00_00;
            4'd10:   rcon = 32'h36_00_00_00;
            default: rcon = 32'h00_00_00_00;  // round 0 / 11-15 unused
        endcase
    end

    assign temp = substituted ^ rcon;

    // w[i] <- w[i-Nk] xor temp, where temp = w[i-1] for i mod 4 != 0  (Alg. 2, line 14)
    logic [31:0] n0, n1, n2, n3;
    assign n0 = w0 ^ temp;   // i mod 4 == 0
    assign n1 = w1 ^ n0;
    assign n2 = w2 ^ n1;
    assign n3 = w3 ^ n2;

    assign next_key = {n0, n1, n2, n3};

endmodule
