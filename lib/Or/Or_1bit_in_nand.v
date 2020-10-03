`timescale 1ns/1ps

module Or_1bit_in_nand (out, a, b);
input a;
input b;
output out;

wire a_n;
wire b_n;

Not_1bit_in_nand not_1bit_in_nand_0 (a_n, a);
Not_1bit_in_nand not_1bit_in_nand_1 (b_n, b);
nand nand0 (out, a_n, b_n);

endmodule