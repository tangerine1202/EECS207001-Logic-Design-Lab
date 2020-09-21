`timescale 1ns/1ps

// TODO: rename args
module Eq_1bit (a, b, a_eq_b);
input a, b;
output a_eq_b;
wire c, d;

or (c, a, b);
nand (d, a, b);
nand (a_eq_b, c, d);

endmodule;