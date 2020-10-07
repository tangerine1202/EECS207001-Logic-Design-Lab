`timescale 1ns/1ps

module Or_8bits_in_nor (out, a);
input [8-1:0] a;
output out;

wire out_n;

nor nor0 (out_n, a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]);
Not_1bit_in_nor not_1bit_in_nor (out, out_n);

endmodule