`timescale 1ns/1ps

module Not_1bit_in_nand (out, a);
input a;
output out;

nand nand0 (out, a, a);

endmodule