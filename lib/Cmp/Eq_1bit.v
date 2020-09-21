`timescale 1ns/1ps

module Eq_1bit (out, a, b);
input a, b;
output out;
wire c, d;

or (c, a, b);
nand (d, a, b);
nand (out, c, d);

endmodule