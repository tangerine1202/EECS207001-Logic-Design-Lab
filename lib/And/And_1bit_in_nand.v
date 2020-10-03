`timescale 1ns/1ps

module And_1bit_in_nand (out, a, b);
input a;
input b;
output out;

wire out_n;

nand nand0 (out_n, a, b);
Not_1bit_in_nand not_1bit_in_nand_0 (out, out_n);

endmodule