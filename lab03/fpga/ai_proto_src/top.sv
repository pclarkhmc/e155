// -----------------------------------------------------------------------------
// top: Lattice iCE40 UP5K board wrapper
//
// This wrapper holds only the device-specific parts:
//   * HSOSC internal oscillator (48 MHz nominal). CLKHF_DIV = "0b01" divides
//     it by 2 to about 24 MHz, the closest setting to the ~20 MHz target. If
//     you pick another divider ("0b00"=48, "0b10"=12, "0b11"=6 MHz), change
//     CLK_HZ to match.
//   * Open-drain column pins. A column is driven low or left in high-Z, never
//     driven high.
//
// Pin constraints to add (Radiant .pdc / nextpnr .pcf):
//   * Turn on the internal PULL-UP on rows_n[3:0]. Without it, rows float.
//   * On Radiant, HSOSC comes from the iCE40UP library. With yosys/nextpnr,
//     use SB_HFOSC with the same ports (see comment below).
// -----------------------------------------------------------------------------
module top (
  input  logic       reset_n,   // active-low push button
  input  logic [3:0] rows_n,    // keypad rows (pulled up, active-low)
  output tri   [3:0] cols_n,    // keypad columns (open-drain, active-low)
  output logic [6:0] seg,       // {g,f,e,d,c,b,a}
  output logic [1:0] dig_en     // [1] = left (older), [0] = right (recent)
);
  localparam int unsigned CLK_HZ = 24_000_000;

  logic clk;

  // Radiant primitive. For the open-source flow, replace with:
  //   SB_HFOSC #(.CLKHF_DIV("0b01")) hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));
  HSOSC #(.CLKHF_DIV("0b01")) hf_osc (
    .CLKHFPU (1'b1),
    .CLKHFEN (1'b1),
    .CLKHF   (clk)
  );

  logic [3:0] col_drive;

  keypad_display_core #(
    .CLK_HZ         (CLK_HZ),
    .SCAN_HZ        (200),
    .MUX_HZ         (20_000),
    .PHASE_TICKS    (20),
    .BLANK_TICKS    (1),
    .SEG_ACTIVE_LOW (1'b1),   // common-anode display
    .DIG_ACTIVE_LOW (1'b1)    // PNP high-side digit drivers
  ) u_core (
    .clk       (clk),
    .reset_n   (reset_n),
    .rows_n    (rows_n),
    .col_drive (col_drive),
    .seg       (seg),
    .dig_en    (dig_en)
  );

  // Open-drain columns: '0' when selected, released otherwise.
  // Pressing two keys in one row therefore can't short a low driver
  // to a high driver.
  for (genvar i = 0; i < 4; i++) begin : g_col_od
    assign cols_n[i] = col_drive[i] ? 1'b0 : 1'bz;
  end

endmodule
