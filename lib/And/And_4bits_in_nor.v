`timescale 1ns/1ps

module And_4bits_in_nor (out, a);
input [4-1:0] a;
output out;

wire [4-1:0] a_n;

Not_1bit_in_nor not_1bit_in_nor_0 [4-1:0] (a_n, a);
nor nor0 (out, a_n[0], a_n[1], a_n[2], a_n[3]);

endmodule