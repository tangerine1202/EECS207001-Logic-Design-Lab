`timescale 1ns/1ps

module _Mux_8bits (out, in1, in0, sel);

input [8-1:0] in0;
input [8-1:0] in1;
input sel;
output [8-1:0] out;

Mux_1bit mux_1bit [8-1:0] (out, in1, in0, sel);

endmodule