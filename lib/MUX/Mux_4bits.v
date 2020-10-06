`timescale 1ns/1ps

module Mux_4bits (out, in1, in0, sel);

input [4-1:0] in0;
input [4-1:0] in1;
input sel;
output [4-1:0] out;

Mux_1bit mux_1bit [4-1:0] (out, in1, in0, sel);

endmodule