// -----------------------------------------------------------------------------
// sync2
//
// Two-flop synchronizer for asynchronous inputs (keypad rows, reset button).
// The key contacts change with no relation to the clock, so without this they
// could send a metastable value into the FSM.
//
// RESET_VAL sets the value the chain resets to and the value it starts with at
// configuration. Keypad rows are active-low and idle high, so the rows
// synchronizer uses '1.
// -----------------------------------------------------------------------------
module sync2 #(
  parameter int unsigned       WIDTH     = 1,
  parameter logic [WIDTH-1:0]  RESET_VAL = '0
) (
  input  logic             clk,
  input  logic             rst,    // synchronous, active-high
  input  logic [WIDTH-1:0] d,      // asynchronous input
  output logic [WIDTH-1:0] q       // synchronized output
);
  logic [WIDTH-1:0] meta;

  always_ff @(posedge clk) begin
    if (rst) begin
      meta <= RESET_VAL;
      q    <= RESET_VAL;
    end else begin
      meta <= d;
      q    <= meta;
    end
  end
endmodule
