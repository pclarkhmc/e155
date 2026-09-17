//------------------------------------------------------------------------------
// time_mux_seven_seg.sv
//
// AI prototype, Task 1: generated from the bare prompt with no files attached.
// Kept verbatim as generated for the lab write-up; do not "fix" this copy.
//
// Time-multiplexes a single 4-bit to seven-segment decoder between two digits.
// Common anode display, so the segment outputs are active low.
//------------------------------------------------------------------------------
module time_mux_seven_seg #(
    parameter int CLK_FREQ_HZ = 50_000_000,  // input clock frequency
    parameter int REFRESH_HZ  = 500          // per-digit refresh rate
) (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [3:0] digit0,   // first set of input bits
    input  logic [3:0] digit1,   // second set of input bits
    output logic [6:0] seg0,     // first set of seven output bits
    output logic [6:0] seg1      // second set of seven output bits
);

    localparam int DIVISOR   = CLK_FREQ_HZ / (2 * REFRESH_HZ);
    localparam int CNT_WIDTH = $clog2(DIVISOR);

    logic [CNT_WIDTH-1:0] refresh_cnt;
    logic                 sel;      // 0 selects digit0, 1 selects digit1
    logic [3:0]           nibble;   // shared decoder input
    logic [6:0]           seg;      // shared decoder output

    // Refresh clock divider: toggles sel at 2 * REFRESH_HZ
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            refresh_cnt <= '0;
            sel         <= 1'b0;
        end else if (refresh_cnt == CNT_WIDTH'(DIVISOR - 1)) begin
            refresh_cnt <= '0;
            sel         <= ~sel;
        end else begin
            refresh_cnt <= refresh_cnt + 1'b1;
        end
    end

    // Input mux: a single decoder is shared by both digits
    assign nibble = sel ? digit1 : digit0;

    // The one and only seven segment decoder, active low, ordered {g,f,e,d,c,b,a}
    always_comb begin
        unique case (nibble)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
            default: seg = 7'b1111111;
        endcase
    end

    // Output demux: latch the decoder result into the digit that was selected
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            seg0 <= 7'b1111111;
            seg1 <= 7'b1111111;
        end else if (sel) begin
            seg1 <= seg;
        end else begin
            seg0 <= seg;
        end
    end

endmodule
