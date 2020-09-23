`timescale 1ns/1ps

module Decoder (din, dout);

parameter SIZE_IN = 4;
parameter SIZE_OUT = 16;
parameter SIZE_OUT_HALF = SIZE_OUT/2;

input [SIZE_IN-1:0] din;
output [SIZE_OUT-1:0] dout;

// Since din_n[3] isn't be used, -1 one more time.
wire [SIZE_IN-1-1:0] din_n;
wire [3-1:0] decoder_3x8_in;
wire [SIZE_OUT_HALF-1:0] dout_n;

// Inverse input
not not0 (din_n[0], din[0]);
not not1 (din_n[1], din[1]);
not not2 (din_n[2], din[2]);

// Select input
Mux_3bits mux_3bits_0 (
  .in0(din[3-1:0]),
  .in1(din_n[3-1:0]),
  .sel(din[3]),
  .out(decoder_3x8_in)
);

// Decode input
Decoder_3x8 decoder_3x8_0 (
  .sel(decoder_3x8_in),
  .out(dout[SIZE_OUT_HALF-1:0])
);

// Duplicate decoder output
not not4 [SIZE_OUT_HALF-1:0] (dout_n, dout[SIZE_OUT_HALF-1:0]);
not not5 [SIZE_OUT_HALF-1:0] (dout[SIZE_OUT-1:SIZE_OUT_HALF], dout_n);

endmodule
