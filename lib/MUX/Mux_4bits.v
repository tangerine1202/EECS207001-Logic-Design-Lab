`timescale 1ns/1ps

// TODO: rename args
module Mux_4bit(a, b, sel, f);

parameter SIZE = 4;

input [SIZE-1:0] a, b;
input sel;
output [SIZE-1:0] f;

Mux_1bit mux_1bit_0 (a[0], b[0], sel, f[0]);
Mux_1bit mux_1bit_1 (a[1], b[1], sel, f[1]);
Mux_1bit mux_1bit_2 (a[2], b[2], sel, f[2]);
Mux_1bit mux_1bit_3 (a[3], b[3], sel, f[3]);

endmodule