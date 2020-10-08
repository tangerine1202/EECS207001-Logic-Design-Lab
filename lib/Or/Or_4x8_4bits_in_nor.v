`timescale 1ns/1ps

module Or_4x8_4bits_in_nor (out, a);
input [32-1:0] a;
output [4-1:0] out;

wire [4-1:0] out_n;

nor nor0 (out_n[0], a[0], a[0+4], a[0+8], a[0+12], a[0+16], a[0+20], a[0+24], a[0+28]);
nor nor1 (out_n[1], a[1], a[1+4], a[1+8], a[1+12], a[1+16], a[1+20], a[1+24], a[1+28]);
nor nor2 (out_n[2], a[2], a[2+4], a[2+8], a[2+12], a[2+16], a[2+20], a[2+24], a[2+28]);
nor nor3 (out_n[3], a[3], a[3+4], a[3+8], a[3+12], a[3+16], a[3+20], a[3+24], a[3+28]);
Not_1bit_in_nor not_1bit_in_nor [4-1:0] (out, out_n);

endmodule