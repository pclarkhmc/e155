// -----------------------------------------------------------------------------
// keypad_display_core
//
// Portable system: everything except the iCE40 oscillator primitive and the
// tristate pins. It takes `clk` as an input, so the same core runs in
// simulation or on another FPGA.
//
// Data flow:
//   rows_n --sync2--> keypad_scanner --key_valid/key_code--> digit shift reg
//                          ^                                     |
//          scan_tick (clk_divider, ~200 Hz)                      v
//                                                  display_mux --> seg, dig_en
//                                                       ^
//                          mux_tick (clk_divider, ~20 kHz)
// -----------------------------------------------------------------------------
module keypad_display_core #(
  parameter int unsigned CLK_HZ         = 24_000_000,
  parameter int unsigned SCAN_HZ        = 200,     // one column step every 5 ms
  parameter int unsigned MUX_HZ         = 20_000,  // display mux tick
  parameter int unsigned PHASE_TICKS    = 20,      // 500 Hz refresh per digit
  parameter int unsigned BLANK_TICKS    = 1,       // 50 us anti-ghost blanking
  parameter bit          SEG_ACTIVE_LOW = 1'b1,
  parameter bit          DIG_ACTIVE_LOW = 1'b1
) (
  input  logic       clk,
  input  logic       reset_n,     // asynchronous, active-low button
  input  logic [3:0] rows_n,      // raw keypad rows, active-low
  output logic [3:0] col_drive,   // 1 = pull column low (open-drain in top)
  output logic [6:0] seg,
  output logic [1:0] dig_en
);

  // ---------------------------------------------------------------------------
  // Reset: synchronize the button, then use it as a synchronous reset.
  // iCE40 flip-flops start at 0 after configuration, so rst_n_sync starts at
  // 0 and the design comes up in reset without a separate power-on circuit.
  // ---------------------------------------------------------------------------
  logic rst_n_sync, rst;

  sync2 #(.WIDTH(1), .RESET_VAL(1'b0)) u_rst_sync (
    .clk (clk),
    .rst (1'b0),
    .d   (reset_n),
    .q   (rst_n_sync)
  );
  assign rst = ~rst_n_sync;

  // ---------------------------------------------------------------------------
  // Timebases (clock enables; the whole design runs on one clock).
  // ---------------------------------------------------------------------------
  logic scan_tick, mux_tick;

  clk_divider #(.CLK_HZ(CLK_HZ), .TICK_HZ(SCAN_HZ)) u_scan_div (
    .clk      (clk),
    .rst      (rst),
    .tick     (scan_tick),
    .slow_clk ()               // observation-only output, unused here
  );

  clk_divider #(.CLK_HZ(CLK_HZ), .TICK_HZ(MUX_HZ)) u_mux_div (
    .clk      (clk),
    .rst      (rst),
    .tick     (mux_tick),
    .slow_clk ()
  );

  // ---------------------------------------------------------------------------
  // Keypad
  // ---------------------------------------------------------------------------
  logic [3:0] rows_n_sync;
  logic       key_valid;
  logic [3:0] key_code;

  sync2 #(.WIDTH(4), .RESET_VAL(4'b1111)) u_row_sync (
    .clk (clk),
    .rst (rst),
    .d   (rows_n),
    .q   (rows_n_sync)
  );

  keypad_scanner u_scanner (
    .clk       (clk),
    .rst       (rst),
    .scan_tick (scan_tick),
    .rows_n    (rows_n_sync),
    .col_drive (col_drive),
    .key_valid (key_valid),
    .key_code  (key_code)
  );

  // ---------------------------------------------------------------------------
  // Two-entry history: on each new key, the recent digit moves to "older".
  // ---------------------------------------------------------------------------
  logic [3:0] digit_older, digit_recent;

  always_ff @(posedge clk) begin
    if (rst) begin
      digit_older  <= 4'h0;
      digit_recent <= 4'h0;
    end else if (key_valid) begin
      digit_older  <= digit_recent;
      digit_recent <= key_code;
    end
  end

  // ---------------------------------------------------------------------------
  // Display (older on the left, most recent on the right)
  // ---------------------------------------------------------------------------
  display_mux #(
    .PHASE_TICKS    (PHASE_TICKS),
    .BLANK_TICKS    (BLANK_TICKS),
    .SEG_ACTIVE_LOW (SEG_ACTIVE_LOW),
    .DIG_ACTIVE_LOW (DIG_ACTIVE_LOW)
  ) u_display (
    .clk         (clk),
    .rst         (rst),
    .mux_tick    (mux_tick),
    .digit_left  (digit_older),
    .digit_right (digit_recent),
    .seg         (seg),
    .dig_en      (dig_en)
  );

endmodule
