`timescale 1ns/1ps

module Mux_8bits (a, b, c, d, sel1, sel2, sel3, f);

parameter SIZE = 8;

input [SIZE-1:0] a, b, c, d;
input sel1, sel2, sel3;
output [SIZE-1:0] f;

wire [SIZE-1:0] w1, w2;

Mux_8bits mux_8bits_0 (a, b, sel1, w1);
Mux_8bits mux_8bits_1 (c, d, sel2, w2);
Mux_8bits mux_8bits_2 (w1, w2, sel3, f);

endmodule
