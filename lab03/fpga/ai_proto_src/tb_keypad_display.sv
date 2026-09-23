// -----------------------------------------------------------------------------
// Self-checking testbench for keypad_display_core.
// The clock is scaled down (CLK_HZ = 10 kHz) so simulation runs fast. One scan
// tick = 100 clk cycles, one mux tick = 5 clk cycles.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps
module tb_keypad_display;
  localparam int CLK_HZ   = 10_000;
  localparam int SCAN_HZ  = 100;
  localparam int MUX_HZ   = 2_000;
  localparam int TICK_CYC = CLK_HZ / SCAN_HZ;   // clk cycles per scan tick

  logic       clk = 0;
  logic       reset_n;
  logic [3:0] rows_n, col_drive;
  logic [6:0] seg;
  logic [1:0] dig_en;

  always #5 clk = ~clk;

  keypad_display_core #(
    .CLK_HZ(CLK_HZ), .SCAN_HZ(SCAN_HZ), .MUX_HZ(MUX_HZ),
    .PHASE_TICKS(20), .BLANK_TICKS(1),
    .SEG_ACTIVE_LOW(1'b1), .DIG_ACTIVE_LOW(1'b1)
  ) dut (.*);

  // Keypad model: pressed[r][c] joins row r to column c. A row reads low if
  // any pressed key in it sits on a column being pulled low. The row pull-up
  // is modelled as the default '1'.
  logic [3:0] pressed [4];
  always_comb
    for (int r = 0; r < 4; r++) rows_n[r] = ~|(pressed[r] & col_drive);

  // Key layout must match keypad_scanner::decode_key
  function automatic logic [3:0] layout(int r, int c);
    logic [15:0] row_keys;
    case (r)
      0: row_keys = 16'h123A;
      1: row_keys = 16'h456B;
      2: row_keys = 16'h789C;
      default: row_keys = 16'hE0FD;
    endcase
    return row_keys[15 - 4*c -: 4];
  endfunction

  int n_valid = 0;
  logic [3:0] last_code;
  always @(posedge clk) if (dut.key_valid) begin
    n_valid++; last_code = dut.key_code;
  end

  int errors = 0;
  int bad, n_before;
  task automatic check(string what, logic cond);
    if (!cond) begin errors++; $display("FAIL: %s  (t=%0t)", what, $time); end
    else            $display("pass: %s", what);
  endtask

  task automatic wait_ticks(int n); repeat (n * TICK_CYC) @(posedge clk); endtask

  // Press with contact bounce: toggle several times inside one tick period
  task automatic bouncy(int r, int c, bit down);
    for (int i = 0; i < 6; i++) begin
      pressed[r][c] = i[0] ? ~down : down;
      repeat (7 + 3*i) @(posedge clk);
    end
    pressed[r][c] = down;
  endtask

  task automatic press_release(int r, int c, int hold_ticks = 10);
    bouncy(r, c, 1); wait_ticks(hold_ticks);
    bouncy(r, c, 0); wait_ticks(4);
  endtask

  // Watch the display for one full mux cycle, capturing each digit's pattern
  // and its on-time.
  logic [6:0] seen_left, seen_right;
  int         on_left, on_right, overlap;
  task automatic observe_display(int cycles);
    on_left = 0; on_right = 0; overlap = 0;
    repeat (cycles) begin
      @(posedge clk);
      if (dig_en == 2'b11) overlap++;   // both off = blanking
      if (dig_en == 2'b01) begin on_left++;  seen_left  = ~seg; end
      if (dig_en == 2'b10) begin on_right++; seen_right = ~seg; end
    end
  endtask

  function automatic logic [6:0] pat(logic [3:0] h);
    logic [6:0] s;
    case (h)
      4'h0: s=7'h3F; 4'h1: s=7'h06; 4'h2: s=7'h5B; 4'h3: s=7'h4F;
      4'h4: s=7'h66; 4'h5: s=7'h6D; 4'h6: s=7'h7D; 4'h7: s=7'h07;
      4'h8: s=7'h7F; 4'h9: s=7'h6F; 4'hA: s=7'h77; 4'hB: s=7'h7C;
      4'hC: s=7'h39; 4'hD: s=7'h5E; 4'hE: s=7'h79; 4'hF: s=7'h71;
    endcase
    return s;
  endfunction

  initial begin
    foreach (pressed[r]) pressed[r] = '0;
    reset_n = 0;
    repeat (20) @(posedge clk);
    reset_n = 1;
    wait_ticks(4);

    // 1. Bouncy press of '5' must register exactly once
    press_release(1, 1, 20);
    check("bouncy '5' registers exactly once", n_valid == 1 && last_code == 4'h5);
    check("recent digit = 5", dut.digit_recent == 4'h5);

    // 2. Hold 'A'; press '9' (another column) while A is held; release A while
    //    9 is still held; then release 9. Only A may register.
    bouncy(0, 3, 1); wait_ticks(10);
    bouncy(2, 2, 1); wait_ticks(10);
    bouncy(0, 3, 0); wait_ticks(10);
    check("second key ignored while any key held", n_valid == 2 && last_code == 4'hA);
    bouncy(2, 2, 0); wait_ticks(4);
    check("no late registration after full release", n_valid == 2);
    check("digits shift: older=5 recent=A",
          dut.digit_older == 4'h5 && dut.digit_recent == 4'hA);

    // 3. Short glitch (much shorter than one tick) must be rejected by CONFIRM
    for (int i = 0; i < 8; i++) begin   // glitch at many phases vs. the tick
      pressed[3][3] = 1; repeat (3) @(posedge clk);
      pressed[3][3] = 0; repeat (TICK_CYC/2 + 7*i) @(posedge clk);
    end
    wait_ticks(4);
    check("sub-tick glitches rejected", n_valid == 2);

    // 4. Every key decodes correctly
    bad = 0;
    begin
      for (int r = 0; r < 4; r++)
        for (int c = 0; c < 4; c++) begin
          n_before = n_valid;
          press_release(r, c, 6);
          if (n_valid != n_before + 1 || last_code != layout(r, c)) begin
            bad++; $display("  key r%0d c%0d -> %h (n+%0d)", r, c, last_code, n_valid-n_before);
          end
        end
      check("all 16 keys decode once each", bad == 0);
    end

    // 5. Display contents, balance and blanking
    press_release(0, 1, 6);   // '2'
    press_release(2, 0, 6);   // '7'
    observe_display(2 * 20 * (CLK_HZ / MUX_HZ) * 4);
    check("left digit shows older key (2)",  seen_left  == pat(4'h2));
    check("right digit shows recent key (7)", seen_right == pat(4'h7));
    check("balanced on-time (left == right)", on_left == on_right && on_left > 0);
    check("blanking present between digits", overlap > 0);
    $display("  on_left=%0d on_right=%0d blank=%0d", on_left, on_right, overlap);

    $display("\n%0d key registrations total; %0d errors", n_valid, errors);
    if (errors == 0) $display("ALL TESTS PASSED");
    $finish;
  end

  // Never enable both digits together (active-low: 2'b00 = both on)
  always @(posedge clk) if (reset_n && dig_en == 2'b00) begin
    errors++; $display("FAIL: both digits enabled at %0t", $time);
  end
endmodule
