`timescale 1ns/1ps

module Or_1bit_in_nor (out, a, b);
input a;
input b;
output out;

wire out_n;

nor nor0 (out_n, a, b);
Not_1bit_in_nor not_1bit_in_nor (out, out_n);

endmodule