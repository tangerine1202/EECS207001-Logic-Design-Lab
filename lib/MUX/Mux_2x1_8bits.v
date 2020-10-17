`timescale 1ns/1ps

module Mux_2x1_8bits (out, in1, in0, sel);

parameter SIZE = 8;

input [SIZE-1:0] in0;
input [SIZE-1:0] in1;
input sel;
output [SIZE-1:0] out;

Mux_1bit mux_1bit [SIZE-1:0] (out, in1, in0, sel);

endmodule