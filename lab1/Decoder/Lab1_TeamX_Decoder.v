`timescale 1ns/1ps

module Decoder (din, dout);

parameter SIZE_IN = 4;
parameter SIZE_OUT = 16;

input [SIZE_IN-1:0] din;
output [SIZE_OUT-1:0] dout;

wire [SIZE_IN-1:0] din_n;
wire [3-1:0] decoder_3x8_in;
wire [8:0] dout_n;

not not0 (din_n[0], din[0]);
not not1 (din_n[1], din[1]);
not not2 (din_n[2], din[2]);
not not3 (din_n[3], din[3]);

Mux_3bits mux_3bits_0 (
  .in0(din[2:0]),
  .in1(din_n[2:0]),
  .sel(din[3]),
  .out(decoder_3x8_in)
);

Decoder_3x8 decoder_3x8_0 (
  .sel(decoder_3x8_in),
  .out(dout[15:8])
);

// Duplicate decoder output
not not4 (dout_n, dout[15:8]);
not not5 (dout[0], dout_n[0]);
not not6 (dout[1], dout_n[1]);
not not7 (dout[2], dout_n[2]);
not not8 (dout[3], dout_n[3]);
not not9 (dout[4], dout_n[4]);
not not10 (dout[5], dout_n[5]);
not not11 (dout[6], dout_n[6]);
not not12 (dout[7], dout_n[7]);

endmodule
