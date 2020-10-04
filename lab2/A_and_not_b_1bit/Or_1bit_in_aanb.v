`timescale 1ns/1ps

module Or_1bit_in_aanb (out, a, b);
input a;
input b;
output out;

wire out_nor;
Nor_1bit_in_aanb nor_1bit_in_aanb_0 (out_nor, a, b);
Not_1bit_in_aanb not_1bit_in_aanb_0 (out, out_nor);

endmodule