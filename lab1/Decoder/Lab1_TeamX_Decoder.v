`timescale 1ns/1ps

module Decoder (din, dout);

input [4-1:0] din;
output [16-1:0] dout;

// Since din_n[3] isn't be used, -1 one more time.
wire [4-1-1:0] din_n;
wire [3-1:0] decoder_3x8_in;
wire [8-1:0] dout_n;

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
  .out(dout[8-1:0])
);

// Duplicate decoder output
not not4 [8-1:0] (dout_n, dout[8-1:0]);
not not5 [8-1:0] (dout[16-1:8], dout_n);

endmodule


module Mux_1bit (out, in1, in0, sel);

input in0;
input in1;
input sel;
output out;

wire sel_n;
wire and_in_0;
wire and_in_1;

not not0 (sel_n, sel);
and and0 (and_in_1, in1, sel);
and and1 (and_in_0, in0, sel_n);
or  or0  (out, and_in_1, and_in_0);

endmodule


module Mux_3bits (out, in1, in0, sel);

input [3-1:0] in0;
input [3-1:0] in1;
input sel;
output [3-1:0] out;

Mux_1bit mux_1bit [3-1:0] (out, in1, in0, sel);

endmodule


module Decoder_3x8 (out, sel);

input [3-1:0] sel;
output [8-1:0] out;

wire [3-1:0] sel_n;

not not0 (sel_n[0], sel[0]);
not not1 (sel_n[1], sel[1]);
not not2 (sel_n[2], sel[2]);

and and0 (out[0], sel_n[2], sel_n[1], sel_n[0]);
and and1 (out[1], sel_n[2], sel_n[1], sel[0]);
and and2 (out[2], sel_n[2], sel[1], sel_n[0]);
and and3 (out[3], sel_n[2], sel[1], sel[0]);
and and4 (out[4], sel[2], sel_n[1], sel_n[0]);
and and5 (out[5], sel[2], sel_n[1], sel[0]);
and and6 (out[6], sel[2], sel[1], sel_n[0]);
and and7 (out[7], sel[2], sel[1], sel[0]);

endmodule