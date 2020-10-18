`timescale 1ns/1ps

module Memory (clk, ren, wen, addr, din, dout);

// # of words
parameter DEPTH = 128;
// # bits per words
parameter WIDTH = 8;

input clk;
input ren;
input wen;
input [7-1:0] addr;
input [8-1:0] din;
output reg [8-1:0] dout;

// words selector
wire [DEPTH-1:0] sel;
wire [DEPTH-1:0][WIDTH-1:0] word_out;  // DEPTH * WIDTH words
wire [DEPTH-1:0] or_out;

/**
 * Combination circuit:
 * decoder binary 'addr' to one-hot 'sel' to select words
 */
Decoder_7x128 addr_decoder (
  .sel(addr),
  .out(sel)
);

/**
 * 128 * 8-bit words
 * select enabled word by 'sel'
 */
 Word_8bits words_8bits [DEPTH-1:0] (
  .clk(clk),
  .ren(ren),
  .wen(wen),
  .en(sel),
  .din(din),
  .out(word_out)
);


always@(*)
  begin
    for(int index=0; index <DEPTH; index++)
      or_out = or_out | word-out[index];
  end

assign dout = or_out;


/**
 * Combinational circuit:
 * select output of words
 */
// Mux_128x1_8bits output_mux (
//   .in(word_out),
//   .sel(sel),
//   .out(dout)
// );

endmodule

module Word_8bits (clk, out, ren, wen, en, din);

parameter WIDTH = 8;

input clk;              // clk
input ren;              // read-enable
input wen;              // write-enable
input en;               // enable
input [WIDTH-1:0] din;  // data-in
output reg out;             // output

reg [WIDTH-1:0] mem;

/**
 * Sequential Circuit:
 * control 'mem' and 'out'
 */
always @(posedge clk) begin
  if (en == 1'b1) begin
    // Only update when this word is enabled
    if (ren == 1'b1) begin
      // Read 'mem' to 'out'
      mem <= mem;
      out <= mem;
    end
    else if (wen == 1'b1) begin
      // Write 'din' to 'mem'
      mem <= din;
      out <= 8'b0;
    end
    else begin
      // Do nothing
      mem <= mem;
      out <= 8'b0;
    end
  end
  else begin
    // Do nothing
    mem <= mem;
    out <= 8'b0;
  end
end

endmodule
