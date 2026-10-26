/////////////////////////////////////////////
// aes_core
//   top level AES encryption module
//   when load is asserted, takes the current key and plaintext
//   generates cyphertext and asserts done when complete 11 cycles later
// 
//   See FIPS-197 with Nk = 4, Nb = 4, Nr = 10
//
//   The key and message are 128-bit values packed into an array of 16 bytes as
//   shown below
//        [127:120] [95:88] [63:56] [31:24]     S0,0    S0,1    S0,2    S0,3
//        [119:112] [87:80] [55:48] [23:16]     S1,0    S1,1    S1,2    S1,3
//        [111:104] [79:72] [47:40] [15:8]      S2,0    S2,1    S2,2    S2,3
//        [103:96]  [71:64] [39:32] [7:0]       S3,0    S3,1    S3,2    S3,3
//
//   Equivalently, the values are packed into four words as given
//        [127:96]  [95:64] [63:32] [31:0]      w[0]    w[1]    w[2]    w[3]
/////////////////////////////////////////////

module aes_core(input  logic         clk, 
                input  logic         load,
                input  logic [127:0] key, 
                input  logic [127:0] plaintext, 
                output logic         done, 
                output logic [127:0] cyphertext);
	
	logic old_load, start, en;
	logic cypher_done;
	logic [3:0] round;
	logic [4:0] count;
	assign start = load != old_load;
	
	always_ff @(posedge clk) begin
		// track load 
		old_load <= load;
		
		// load handling logic
		if (load) round <= 0;
		if (start) count <= 0;
		else count <= count + 1; // count logic 
		
		// on high count, increment round and cycle en
		if (cypher_done && (round < 10)) begin
				round <= round + 1;
				en <= 1;
			end
		else begin
			round <= round;
				en <= 0;
		end
			
		// done logic
		if (round == 10) done <= 1;
		else done <= 0;
		
	end
	
	// Per round logic: control signals
	logic [1:0] sel;
	always_comb begin
		if (round == 0)
			begin
				sel <= 0; // input key_in
			end
		else if (round == 10) 
			begin
				sel <= 1; // skip stage
			end
		else  
			begin
				sel <= 2; // round 1-9
			end
	end 
	
	// key expansion
	logic key_ready;
	logic [127:0] key_out;
	keyexpansion_controller keyexpansion_controller(.clk(clk), .reset(start), .round(round),.key_in(key),.key_out(key_out),.key_ready(key_ready));
	
	// cipher_core
	cipher_core cipher_core(.clk(clk), .en(en), .reset(en), .sel(sel), .plaintext(plaintext), .key_in(key_out), .cyphertext(cyphertext), .done(cypher_done)); 
		
endmodule
