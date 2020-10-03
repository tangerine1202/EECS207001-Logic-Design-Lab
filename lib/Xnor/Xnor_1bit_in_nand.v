`timescale 1ns/1ps

module Xnor_1bit_in_nand (out, a, b);

input a;
input b;
output out;

wire c, d;

nand nand0 (c, a, b);
Or_1bit_in_nand or_1bit_in_nand_0 (d, a, b);
nand nand1 (out, c, d);

endmodule