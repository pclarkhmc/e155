// -----------------------------------------------------------------------------
// keypad_scanner
//
// Scans a 4x4 matrix keypad and emits exactly one `key_valid` pulse per press.
//
// Hardware assumptions:
//   * Rows are inputs with pull-ups (enable the FPGA's internal pull-ups on the
//     row pins). A pressed key connects its row to its column.
//   * Columns are driven active-low, one at a time. `col_drive[i] = 1` means
//     "pull column i low". The top level turns this into an open-drain pin
//     (0 or Z). Two keys pressed in one row can then never short a
//     driven-low column to a driven-high one.
//
// Debounce by design (no separate debounce counter):
//   * State changes and row samples happen only on `scan_tick`
//     (~200 Hz, so 5 ms apart). Most contact bounce settles within that time.
//   * SCAN    : drive one column; if any row reads low, remember the row
//               pattern and go to CONFIRM, otherwise move to the next column.
//   * CONFIRM : one tick later, the same column must show the same row pattern.
//               This rejects single-sample glitches and bounce on press. If the
//               pattern matches, register the key (one pulse) and go to HOLD.
//   * HOLD    : drive ALL columns low. Now any key anywhere on the pad pulls a
//               row low, so "rows all high" means no key is held at all. While
//               any key is held nothing is registered, including keys pressed
//               in other columns.
//   * RELEASE : rows must read all-high on two ticks in a row (≥5 ms) before
//               scanning starts again. This stops release bounce from registering
//               a second press.
// -----------------------------------------------------------------------------
module keypad_scanner (
  input  logic       clk,
  input  logic       rst,         // synchronous, active-high
  input  logic       scan_tick,   // clock enable from clk_divider
  input  logic [3:0] rows_n,      // synchronized, active-low rows
  output logic [3:0] col_drive,   // 1 = pull that column low
  output logic       key_valid,   // 1-cycle pulse when a new key registers
  output logic [3:0] key_code     // hex value of the registered key
);

  typedef enum logic [1:0] {
    S_SCAN,
    S_CONFIRM,
    S_HOLD,
    S_RELEASE
  } state_t;

  state_t     state;
  logic [1:0] col;         // column currently being scanned
  logic [3:0] row_latch;   // row pattern seen in SCAN, re-checked in CONFIRM

  logic any_pressed;
  assign any_pressed = (rows_n != 4'b1111);

  // ---------------------------------------------------------------------------
  // Keypad layout -> hex code. Edit the case table below to match your keypad.
  //           col0 col1 col2 col3
  //   row0:    1    2    3    A
  //   row1:    4    5    6    B
  //   row2:    7    8    9    C
  //   row3:    E(*) 0    F(#) D
  // ---------------------------------------------------------------------------
  logic [1:0] row_idx;     // row of the pressed key (from the current sample)
  logic [3:0] code_now;    // hex code for (row_idx, col)

  // If two keys in the same column are pressed at the same moment, take the
  // lowest-numbered row so the result is always deterministic.
  always_comb begin
    if      (!rows_n[0]) row_idx = 2'd0;
    else if (!rows_n[1]) row_idx = 2'd1;
    else if (!rows_n[2]) row_idx = 2'd2;
    else                 row_idx = 2'd3;
  end

  always_comb begin
    unique case ({row_idx, col})
      4'b0000: code_now = 4'h1;  4'b0001: code_now = 4'h2;
      4'b0010: code_now = 4'h3;  4'b0011: code_now = 4'hA;
      4'b0100: code_now = 4'h4;  4'b0101: code_now = 4'h5;
      4'b0110: code_now = 4'h6;  4'b0111: code_now = 4'hB;
      4'b1000: code_now = 4'h7;  4'b1001: code_now = 4'h8;
      4'b1010: code_now = 4'h9;  4'b1011: code_now = 4'hC;
      4'b1100: code_now = 4'hE;  4'b1101: code_now = 4'h0;
      4'b1110: code_now = 4'hF;  4'b1111: code_now = 4'hD;
    endcase
  end

  // ---------------------------------------------------------------------------
  // State register and datapath. Everything advances only on scan_tick.
  // ---------------------------------------------------------------------------
  always_ff @(posedge clk) begin
    if (rst) begin
      state     <= S_SCAN;
      col       <= 2'd0;
      row_latch <= 4'b1111;
      key_valid <= 1'b0;
      key_code  <= 4'h0;
    end else begin
      key_valid <= 1'b0;                         // default: pulse lasts one cycle

      if (scan_tick) begin
        unique case (state)
          S_SCAN: begin
            if (any_pressed) begin
              row_latch <= rows_n;               // keep column fixed, confirm next tick
              state     <= S_CONFIRM;
            end else begin
              col <= col + 2'd1;                 // nothing here: next column
            end
          end

          S_CONFIRM: begin
            if (rows_n == row_latch) begin
              key_code  <= code_now;
              key_valid <= 1'b1;                 // the only place a key registers
              state     <= S_HOLD;
            end else begin
              state <= S_SCAN;                   // glitch/bounce: sample this column again
            end
          end

          S_HOLD: begin
            if (!any_pressed) state <= S_RELEASE;
          end

          S_RELEASE: begin
            if (!any_pressed) begin
              col   <= col + 2'd1;
              state <= S_SCAN;                   // released cleanly: accept new keys again
            end else begin
              state <= S_HOLD;                   // release bounce or another key: keep waiting
            end
          end
        endcase
      end
    end
  end

  // ---------------------------------------------------------------------------
  // Column drive: one column in SCAN/CONFIRM, all columns in HOLD/RELEASE.
  // This decodes state registers only. A brief decode glitch doesn't matter
  // because rows aren't sampled until the next tick, milliseconds later.
  // ---------------------------------------------------------------------------
  always_comb begin
    unique case (state)
      S_SCAN, S_CONFIRM: col_drive = 4'b0001 << col;
      default:           col_drive = 4'b1111;
    endcase
  end

endmodule
