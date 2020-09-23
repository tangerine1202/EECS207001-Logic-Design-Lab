`timescale 1ns/1ps

module Mux_4bits(out, in0, in1, sel);

parameter SIZE = 4;

input [SIZE-1:0] in0, in1;
input sel;
output [SIZE-1:0] out;

Mux_1bit mux_1bit_0 (out[0], in0[0], in1[0], sel);
Mux_1bit mux_1bit_1 (out[1], in0[1], in1[1], sel);
Mux_1bit mux_1bit_2 (out[2], in0[2], in1[2], sel);
Mux_1bit mux_1bit_3 (out[3], in0[3], in1[3], sel);

endmodule