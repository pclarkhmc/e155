// -----------------------------------------------------------------------------
// hex_to_7seg
//
// Hex digit to 7-segment pattern. Output is ACTIVE-HIGH, bit order {g,f,e,d,c,b,a}.
// display_mux applies board polarity, so this decoder stays independent of
// the board.
//
//        a
//      f   b
//        g
//      e   c
//        d
// -----------------------------------------------------------------------------
module hex_to_7seg (
  input  logic [3:0] hex,
  output logic [6:0] seg    // {g,f,e,d,c,b,a}, 1 = segment on
);
  always_comb begin
    unique case (hex)
      4'h0: seg = 7'b011_1111;
      4'h1: seg = 7'b000_0110;
      4'h2: seg = 7'b101_1011;
      4'h3: seg = 7'b100_1111;
      4'h4: seg = 7'b110_0110;
      4'h5: seg = 7'b110_1101;
      4'h6: seg = 7'b111_1101;
      4'h7: seg = 7'b000_0111;
      4'h8: seg = 7'b111_1111;
      4'h9: seg = 7'b110_1111;
      4'hA: seg = 7'b111_0111;
      4'hB: seg = 7'b111_1100;   // lowercase b
      4'hC: seg = 7'b011_1001;
      4'hD: seg = 7'b101_1110;   // lowercase d
      4'hE: seg = 7'b111_1001;
      4'hF: seg = 7'b111_0001;
    endcase
  end
endmodule
