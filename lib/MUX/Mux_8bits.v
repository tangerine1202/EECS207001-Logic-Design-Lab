`timescale 1ns/1ps

// TODO: rename args
module Mux_8bit(a, b, sel, f);

parameter SIZE = 8;

input [SIZE-1:0] a, b;
input sel;
output [SIZE-1:0] f;

Mux_1bit mux_1bit_0 (a[0], b[0], sel, f[0]);
Mux_1bit mux_1bit_1 (a[1], b[1], sel, f[1]);
Mux_1bit mux_1bit_2 (a[2], b[2], sel, f[2]);
Mux_1bit mux_1bit_3 (a[3], b[3], sel, f[3]);
Mux_1bit mux_1bit_4 (a[4], b[4], sel, f[4]);
Mux_1bit mux_1bit_5 (a[5], b[5], sel, f[5]);
Mux_1bit mux_1bit_6 (a[6], b[6], sel, f[6]);
Mux_1bit mux_1bit_7 (a[7], b[7], sel, f[7]);

endmodule