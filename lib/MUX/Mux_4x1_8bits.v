// FIXME: untested, may un-runable or act incorrect.
`timescale 1ns/1ps

module Mux_4x1_8bits (out, in, sel);

parameter SIZE_SEL = 2;
parameter SIZE_M = 4;
parameter SIZE_N = 8;

input [SIZE_N-1:0] in [SIZE_M-1:0];  // an <SIZE_N>-bit vector with a depth of <SIZE_M>
input [SIZE_SEL-1:0] sel;
output [SIZE_N-1:0] out;

wire [SIZE_N-1:0] out0;
wire [SIZE_N-1:0] out1;

Mux_2x1_8bits mux_2x1_8bits_0 (
  .in0(in[0]),
  .in1(in[1]),
  .sel(sel[0]),
  .out(out0)
);

Mux_2x1_8bits mux_2x1_8bits_1 (
  .in0(in[2]),
  .in1(in[3]),
  .sel(sel[0]),
  .out(out1)
);

Mux_2x1_8bits mux_2x1_8bits_2 (
  .in0(out0),
  .in1(out1),
  .sel(sel[1]),
  .out(out)
);

endmodule