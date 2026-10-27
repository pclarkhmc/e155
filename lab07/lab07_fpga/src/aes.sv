/////////////////////////////////////////////
// aes
//   Top level module with SPI interface and SPI core
/////////////////////////////////////////////

module aes(
           input  logic sck, 
           input  logic sdi,
           output logic sdo,
           input  logic load,
           output logic done);
		   
		   
	// declare an internal clock of 48 Mhz
	logic int_clk;
	HSOSC #(.CLKHF_DIV(2'b01))
		 hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_clk));
		 
    logic [127:0] key, plaintext, cyphertext;
    aes_spi spi(sck, sdi, sdo, done, key, plaintext, cyphertext);   
    aes_core core(int_clk, load, key, plaintext, done, cyphertext);
endmodule
