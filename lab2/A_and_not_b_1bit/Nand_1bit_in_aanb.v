`timescale 1ns/1ps

module Nand_1bit_in_aanb (out, a, b);
input a;
input b;
output out;

wire out_and;
And_1bit_in_aanb and_1bit_in_aanb_0 (out_and, a, b);
Not_1bit_in_aanb not_1bit_in_aanb_0 (out, out_and);

endmodule