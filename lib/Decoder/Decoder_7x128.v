`timescale 1ns/1ps

module Decoder_7x128 (out, sel);

parameter SIZE_IN = 7;
parameter SIZE_OUT = 128;

wire [SIZE_OUT/2:0] half_out;

Decoder_6x64 half_decoder (
  .sel(sel[SIZE_IN-1-1:0]),
  .out(half_out)
);

Mux_2x1_128bits mux (
  .in0({64'b0, half_out}),
  .in1({half_out, 64'b0}),
  .sel(sel[SIZE_IN-1]),
  .out(out)
);


endmodule

module Mux_2x1_128bits (out, in1, in0, sel);

parameter SIZE = 128;

input [SIZE-1:0] in0;
input [SIZE-1:0] in1;
input sel;
output [SIZE-1:0] out;

Mux_1bit mux_1bit [SIZE-1:0] (out, in1, in0, sel);

endmodule