// Synthesis-only copy of prompt2_no_spec/word_expand.sv: unpacked-array ports changed to
// packed arrays because yosys 0.52 cannot parse unpacked-array ports. Logic is unchanged.
// Unrolled implementation of the word-expansion loop.
//
//   Nk : number of 32-bit words supplied by the key
//   Nr : sets the output length -> words w[0] .. w[4*Nr+3]
//
// key  : byte array, key[0] .. key[4*Nk-1]
// rcon : lookup table indexed by i/Nk (supplied externally)
// w    : expanded word array, w[0] .. w[4*Nr+3]
module word_expand_packed #(
  parameter int Nk = 4,
  parameter int Nr = 10
)(
  input  logic [0:4*Nk-1][7:0] key,
  input  logic [0:(4*Nr+3)/Nk][31:0] rcon,
  output logic [0:4*Nr+3][31:0] w
);

  genvar i;
  generate
    // ------------------------------------------------------------
    // First loop:  w[i] <- key[4*i .. 4*i+3]   for i = 0 .. Nk-1
    // ------------------------------------------------------------
    for (i = 0; i < Nk; i++) begin : g_init
      assign w[i] = {key[4*i], key[4*i+1], key[4*i+2], key[4*i+3]};
    end

    // ------------------------------------------------------------
    // Second loop, unrolled: i = Nk .. 4*Nr+3
    // Each stage uses the previous stage's output w[i-1]
    // and the earlier word w[i-Nk].
    // ------------------------------------------------------------
    for (i = Nk; i <= 4*Nr+3; i++) begin : g_expand
      logic [31:0] temp_in;   // temp <- w[i-1]
      logic [31:0] temp;      // temp after the conditional processing

      assign temp_in = w[i-1];

      if (i % Nk == 0) begin : g_case_mod0
        // temp <- module1(module2(temp)) XOR Rcon[i/Nk]
        logic [31:0] m2_out, m1_out;

        module2 u_module2 (.in(temp_in), .out(m2_out));
        module1 u_module1 (.in(m2_out),  .out(m1_out));

        assign temp = m1_out ^ rcon[i/Nk];
      end
      else if ((Nk > 6) && (i % Nk == 4)) begin : g_case_mod4
        // temp <- module1(temp)
        logic [31:0] m1_out;

        module1 u_module1 (.in(temp_in), .out(m1_out));

        assign temp = m1_out;
      end
      else begin : g_case_pass
        // temp unchanged
        assign temp = temp_in;
      end

      // w[i] <- w[i-Nk] XOR temp
      assign w[i] = w[i-Nk] ^ temp;
    end
  endgenerate

endmodule
