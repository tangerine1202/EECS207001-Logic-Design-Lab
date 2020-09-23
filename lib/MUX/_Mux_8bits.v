`timescale 1ns/1ps

module _Mux_8bits (out, in1, in0, sel);

parameter SIZE = 8;

input [SIZE-1:0] in0;
input [SIZE-1:0] in1;
input sel;
output [SIZE-1:0] out;

Mux_1bit mux_1bit_0 (out[0], in1[0], in0[0], sel);
Mux_1bit mux_1bit_1 (out[1], in1[1], in0[1], sel);
Mux_1bit mux_1bit_2 (out[2], in1[2], in0[2], sel);
Mux_1bit mux_1bit_3 (out[3], in1[3], in0[3], sel);
Mux_1bit mux_1bit_4 (out[4], in1[4], in0[4], sel);
Mux_1bit mux_1bit_5 (out[5], in1[5], in0[5], sel);
Mux_1bit mux_1bit_6 (out[6], in1[6], in0[6], sel);
Mux_1bit mux_1bit_7 (out[7], in1[7], in0[7], sel);

endmodule