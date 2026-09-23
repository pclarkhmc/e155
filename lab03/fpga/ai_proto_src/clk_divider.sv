// -----------------------------------------------------------------------------
// clk_divider
//
// Derives a slow timebase from the fast system clock.
//
// Design choice: the primary output is a single-cycle clock ENABLE (`tick`),
// not a new clock. Every flip-flop in the design stays on the one oscillator
// clock and advances only when `tick` is high. That avoids routing a
// fabric-generated clock (skew, no global buffer, clock-domain crossings) and
// keeps all state synchronous, which is what the iCE40 timing tools expect.
//
// `slow_clk` is a 50%-duty square wave at the same rate. It's there only for
// probing on a scope/LED. Don't use it to clock logic.
// -----------------------------------------------------------------------------
module clk_divider #(
  parameter int unsigned CLK_HZ  = 24_000_000,  // input clock frequency
  parameter int unsigned TICK_HZ = 200          // desired tick rate
) (
  input  logic clk,
  input  logic rst,       // synchronous, active-high
  output logic tick,      // 1-cycle pulse at TICK_HZ
  output logic slow_clk   // 50% duty square wave at TICK_HZ (observation only)
);
  localparam int unsigned DIV = CLK_HZ / TICK_HZ;
  localparam int unsigned W   = (DIV > 1) ? $clog2(DIV) : 1;

  // Stop synthesis early if someone sets TICK_HZ above CLK_HZ / 2.
  initial begin
    if (DIV < 2) $error("clk_divider: TICK_HZ must be <= CLK_HZ/2");
  end

  logic [W-1:0] count;

  always_ff @(posedge clk) begin
    if (rst) begin
      count    <= '0;
      tick     <= 1'b0;
      slow_clk <= 1'b0;
    end else begin
      if (count == W'(DIV - 1)) begin
        count <= '0;
        tick  <= 1'b1;
      end else begin
        count <= count + 1'b1;
        tick  <= 1'b0;
      end
      slow_clk <= (count >= W'(DIV / 2));
    end
  end
endmodule
