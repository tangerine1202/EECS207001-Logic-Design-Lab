`timescale 1ns/1ps

module And_1bit_in_aanb (out, a, b);
input a;
input b;
output out;

wire b_n;

Not_1bit_in_aanb not_1bit_in_aanb_0 (b_n, b);
A_and_not_b_1bit aanb0 (out, a, b_n);

endmodule