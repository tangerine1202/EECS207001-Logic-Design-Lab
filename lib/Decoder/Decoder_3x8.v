`timescale 1ns/1ps

module Decoder_3x8 (out, sel);

parameter SIZE_IN = 3;
parameter SIZE_OUT = 8;

input [SIZE_IN-1:0] sel;
output [SIZE_OUT-1:0] out;

wire [SIZE_IN-1:0] sel_n;

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