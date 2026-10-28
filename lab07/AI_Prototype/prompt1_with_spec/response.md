Below is a combinational AES-128 KeyExpansion module, based on Section 5.2 of FIPS-197 (Algorithm 2, Table 5 and Figure 6). It takes the previous round key and a round number and produces the next round key.

**How the spec maps to hardware**

For AES-128, Nk = 4, so each round key is 4 words. Generating round key `r` (words `w[4r]` to `w[4r+3]`) from round key `r-1` (`w[4r-4]` to `w[4r-1]`) works like this:

- `w[4r]   = w[4r-4] ⊕ SubWord(RotWord(w[4r-1])) ⊕ Rcon[r]`
- `w[4r+1] = w[4r-3] ⊕ w[4r]`
- `w[4r+2] = w[4r-2] ⊕ w[4r+1]`
- `w[4r+3] = w[4r-1] ⊕ w[4r+2]`

This is the chain of XORs shown in Figure 6. Only the first word of each new round key goes through RotWord, SubWord and Rcon. Each of the other words is the old word in the same position XORed with the new word just before it.

**Byte ordering:** I use the usual packing, where byte `in0` / `a0` sits in the most significant byte. So `prev_key[127:96]` is word `w0`, and within a word `[31:24]` is `a0`. That makes `RotWord([a0,a1,a2,a3]) = [a1,a2,a3,a0]`, which is `{w[23:0], w[31:24]}`.

```systemverilog
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
```

**Assumed interfaces for the existing modules.** If your port names differ, change the two instantiations to match.

```systemverilog
// RotWord([a0,a1,a2,a3]) = [a1,a2,a3,a0]          (Eq. 5.10)
module rotword (input logic [31:0] a, output logic [31:0] y);
// SubWord([a0..a3]) = [SBox(a0),...,SBox(a3)]     (Eq. 5.11)
module subword (input logic [31:0] a, output logic [31:0] y);
```

**Testbench using the spec's own example (Appendix A.1)**

```systemverilog
module keyexpansion_tb;
    logic [127:0] prev_key, next_key;
    logic [3:0]   round;

    keyexpansion dut (.prev_key(prev_key), .round(round), .next_key(next_key));

    initial begin
        // Round 1: cipher key -> w[4..7]
        prev_key = 128'h2b7e1516_28aed2a6_abf71588_09cf4f3c;
        round    = 4'd1;
        #1;
        assert (next_key == 128'ha0fafe17_88542cb1_23a33939_2a6c7605)
            else $error("Round 1 mismatch: %h", next_key);

        // Round 2: w[4..7] -> w[8..11]
        prev_key = next_key;
        round    = 4'd2;
        #1;
        assert (next_key == 128'hf2c295f2_7a96b943_5935807a_7359f67f)
            else $error("Round 2 mismatch: %h", next_key);

        // Round 10: w[36..39] -> w[40..43]  (Rcon = 36)
        prev_key = 128'hac7766f3_19fadc21_28d12941_575c006e;
        round    = 4'd10;
        #1;
        assert (next_key == 128'hd014f9a8_c9ee2589_e13f0cc8_b6630ca6)
            else $error("Round 10 mismatch: %h", next_key);

        $display("KeyExpansion tests done.");
        $finish;
    end
endmodule
```

**Notes**

- **Combinational path:** this module stays combinational only if `subword` is combinational too. If your S-box is a clocked block RAM (a synchronous S-box), its output arrives one cycle late, and your controller has to account for that.
- **Round counter:** `round` here is the round whose key is being generated. A controller would hold the current round key in a register and set `round_key <= next_key` each round. The cipher key itself is used directly for the first AddRoundKey, round 0 (Algorithm 1, line 3).
- **Rcon:** Rcon could also be built by repeatedly applying `xtimes()` to `{01}`, as the spec notes under Table 5. For only 10 values, a lookup table is simpler and faster.
- **Key sizes:** this module handles AES-128 only. AES-192 (Nk = 6) and AES-256 (Nk = 8) don't line up neatly with 4-word round keys. AES-256 also needs an extra SubWord on `w[i-1]` when `i mod 8 = 4` (Algorithm 2, line 11).