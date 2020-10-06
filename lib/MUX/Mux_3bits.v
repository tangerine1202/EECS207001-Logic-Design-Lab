`timescale 1ns/1ps

module Mux_3bits (out, in1, in0, sel);

input [3-1:0] in0;
input [3-1:0] in1;
input sel;
output [3-1:0] out;

Mux_1bit mux_1bit [3-1:0] (out, in1, in0, sel);

endmodule