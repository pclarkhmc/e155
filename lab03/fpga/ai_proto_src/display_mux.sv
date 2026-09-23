// -----------------------------------------------------------------------------
// display_mux
//
// Time-multiplexes two hex digits onto one shared set of segment lines.
//
// Design choices:
//   * No flicker: each digit gets PHASE_TICKS mux ticks per turn. With
//     MUX_HZ = 20 kHz and PHASE_TICKS = 20, each digit refreshes at
//     20e3 / (2*20) = 500 Hz, well above the ~60-100 Hz where flicker shows.
//   * Balanced brightness: both digits use the same counter and the same
//     phase length, so their on-times match exactly (50% duty each, minus
//     the same blanking).
//   * Anti-ghosting: the first BLANK_TICKS of each phase turn both digits
//     off while the segment lines change. Without it, the previous digit's
//     pattern briefly shows on the new digit (driver turn-off delay).
//     Blanking happens in both phases, so brightness stays balanced.
//   * Outputs are registered, so the pins switch cleanly on a clock edge.
//   * Polarity is set by parameters to suit common-anode or common-cathode
//     displays and active-low or active-high digit transistors.
// -----------------------------------------------------------------------------
module display_mux #(
  parameter int unsigned PHASE_TICKS    = 20,  // mux ticks per digit turn
  parameter int unsigned BLANK_TICKS    = 1,   // dead time at start of each turn
  parameter bit          SEG_ACTIVE_LOW = 1'b1,
  parameter bit          DIG_ACTIVE_LOW = 1'b1
) (
  input  logic       clk,
  input  logic       rst,         // synchronous, active-high
  input  logic       mux_tick,    // clock enable from clk_divider
  input  logic [3:0] digit_left,  // older key
  input  logic [3:0] digit_right, // most recent key
  output logic [6:0] seg,         // {g,f,e,d,c,b,a}, board polarity
  output logic [1:0] dig_en       // [1] = left, [0] = right, board polarity
);
  localparam int unsigned PW = (PHASE_TICKS > 1) ? $clog2(PHASE_TICKS) : 1;

  initial begin
    if (BLANK_TICKS >= PHASE_TICKS)
      $error("display_mux: BLANK_TICKS must be < PHASE_TICKS");
  end

  logic          sel;     // 1 = left digit's turn, 0 = right digit's turn
  logic [PW-1:0] phase;

  always_ff @(posedge clk) begin
    if (rst) begin
      sel   <= 1'b0;
      phase <= '0;
    end else if (mux_tick) begin
      if (phase == PW'(PHASE_TICKS - 1)) begin
        phase <= '0;
        sel   <= ~sel;
      end else begin
        phase <= phase + 1'b1;
      end
    end
  end

  logic       blank;
  logic [3:0] hex;
  logic [6:0] seg_on;     // active-high pattern

  assign blank = (phase < PW'(BLANK_TICKS));
  assign hex   = sel ? digit_left : digit_right;

  hex_to_7seg u_dec (.hex(hex), .seg(seg_on));

  // Active-high "what should be lit" before board polarity is applied
  logic [6:0] seg_next;
  logic [1:0] dig_next;
  assign seg_next = blank ? 7'h00 : seg_on;
  assign dig_next = blank ? 2'b00 : (sel ? 2'b10 : 2'b01);

  // Register pin outputs and apply board polarity.
  always_ff @(posedge clk) begin
    if (rst) begin
      seg    <= SEG_ACTIVE_LOW ? 7'h7F : 7'h00;   // all segments off
      dig_en <= DIG_ACTIVE_LOW ? 2'b11 : 2'b00;   // both digits off
    end else begin
      seg    <= SEG_ACTIVE_LOW ? ~seg_next : seg_next;
      dig_en <= DIG_ACTIVE_LOW ? ~dig_next : dig_next;
    end
  end
endmodule
