`timescale 1ns/1ps

module Eq_1bit (out, a, b);

input a;
input b;
output out;

wire c, d;

or or0 (c, a, b);
nand nand0 (d, a, b);
nand nand1 (out, c, d);

endmodule