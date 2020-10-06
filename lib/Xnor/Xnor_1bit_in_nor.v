`timescale 1ns/1ps

module Xnor_1bit_in_nor (out, a, b);
input a;
input b;
output out;

wire and_ab;
wire nor_ab;

And_1bit_in_nor and_1bit_in_nor_0 (and_ab, a, b);
nor nor0 (nor_ab, a, b);
Or_1bit_in_nor or_1bit_in_nor_1 (out, and_ab, nor_ab);

endmodule