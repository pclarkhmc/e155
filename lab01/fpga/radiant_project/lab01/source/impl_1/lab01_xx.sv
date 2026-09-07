/* 
Pierce Clark  pclark@hmc.edu
The top level module for lab 1, contianing clock
*/
module lab01_xx(
	input logic [3:0] s,
	output logic [2:0] led,
	output logic [6:0] seg,
);
	// Led 0 and 1 behavior
	assign led[0] = ^s;
	assign led[1] = &s;
	
	//declare an internal clock
	//High-frequency oscillator. Generates 48MHz nominal clock, ±10%, with user programmable divider. Can drive global clock network or fabric routing.
	logic int_osc;
	HSOSC #(.CLKHF_DIV(2'b01))
		 hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

	// Counter
	counter1 #(
    .DATA_WIDTH (32),
    .DEPTH      (16)
) counter(int_osc, reset, led[2]);
	
	// Assign LED output
	assign led[2] = counter[24];
	
	// Seven segment display logic
	always _comb begin
		case (s)
			4'h0: seg = 7'b0000001;
			4'h1: seg = 7'b1001111;
			4'h2: seg = 7'b1101101;
			4'h3: seg = 7'b0000110;
			4'h4: seg = 7'b1001100;
			4'h5: seg = 7'b0100100;
			4'h6: seg = 7'b0100000;
			4'h7: seg = 7'b0001111;
			4'h8: seg = 7'b0000000;
			4'h9: seg = 7'b0000100;
			4'hA: seg = 7'b0001000;
			4'hB: seg = 7'b1100000;
			4'hC: seg = 7'b0110001;
			4'hD: seg = 7'b1000010;
			4'hE: seg = 7'b0110000;
			4'hF: seg = 7'b0111000;
			default: seg = '0;
		endcase
	end
endmodule