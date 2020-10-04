`timescale 1ns/1ps

module Nor_1bit_in_aanb (out, a, b);
input a;
input b;
output out;

wire a_n;

Not_1bit_in_aanb not_1bit_in_aanb_0 (a_n, a);
A_and_not_b_1bit aanb0 (out, a_n, b);

endmodule