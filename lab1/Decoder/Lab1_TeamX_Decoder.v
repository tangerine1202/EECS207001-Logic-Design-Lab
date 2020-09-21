`timescale 1ns/1ps

module Decoder (din, dout);

parameter SIZE_IN = 4;
parameter SIZE_OUT = 16;

input [SIZE_IN-1:0] din;
output [SIZE_OUT-1:0] dout;

wire [SIZE_IN-1:0] din_n;
wire [3-1:0] decoder_3x8_in;

not not_0 (din_n[0], din[0]);
not not_1 (din_n[1], din[1]);
not not_2 (din_n[2], din[2]);
not not_3 (din_n[3], din[3]);

Mux_3bits mux_3bits_0 (
  .in0(din[2:0]),
  .in1(din_n[2:0]),
  .sel(din[3]),
  .out(decoder_3x8_in)
);

// Duplicate decoder output
Decoder_3x8 decoder_3x8_0 (
  .sel(decoder_3x8_in),
  .out(dout[15:8])
);
Decoder_3x8 decoder_3x8_1 (
  .sel(decoder_3x8_in),
  .out(dout[7:0])
);

endmodule
