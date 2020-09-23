`timescale 1ns/1ps

module Mux_8bits (a, b, c, d, sel1, sel2, sel3, f);

parameter SIZE = 8;

input [SIZE-1:0] a, b, c, d;
input sel1, sel2, sel3;
output [SIZE-1:0] f;

wire [SIZE-1:0] w1, w2;

_Mux_8bits mux_8bits_0 (.in1(a), .in0(b), .sel(sel1), .out(w1));
_Mux_8bits mux_8bits_1 (.in1(c), .in0(d), .sel(sel2), .out(w2));
_Mux_8bits mux_8bits_2 (.in1(w1), .in0(w2), .sel(sel3), .out(f));

endmodule
