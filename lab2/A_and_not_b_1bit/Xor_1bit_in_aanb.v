`timescale 1ns/1ps

module Xor_1bit_in_aanb (out, a, b);
input a;
input b;
output out;

wire aanb, bana;
A_and_not_b_1bit aanb0 (aanb, a, b);
A_and_not_b_1bit aanb1 (bana, b, a);
Or_1bit_in_aanb or_1bit_in_aanb (out, aanb, bana);

endmodule