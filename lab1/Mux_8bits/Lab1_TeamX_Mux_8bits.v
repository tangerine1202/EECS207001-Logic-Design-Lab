`timescale 1ns/1ps

module Mux_8bits (a, b, c, d, sel1, sel2, sel3, f);

input [8-1:0] a, b, c, d;
input sel1, sel2, sel3;
output [8-1:0] f;

wire [8-1:0] w1, w2;

_Mux_8bits mux_8bits_0 (.in1(a), .in0(b), .sel(sel1), .out(w1));
_Mux_8bits mux_8bits_1 (.in1(c), .in0(d), .sel(sel2), .out(w2));
_Mux_8bits mux_8bits_2 (.in1(w1), .in0(w2), .sel(sel3), .out(f));

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


module _Mux_8bits (out, in1, in0, sel);

input [8-1:0] in0;
input [8-1:0] in1;
input sel;
output [8-1:0] out;

Mux_1bit mux_1bit [8-1:0] (out, in1, in0, sel);

endmodule