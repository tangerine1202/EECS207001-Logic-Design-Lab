`timescale 1ns/1ps

module And_1bit_in_nor (out, a, b);
input a;
input b;
output out;

wire a_n;
wire b_n;

Not_1bit_in_nor not_1bit_in_nor_0 (a_n, a);
Not_1bit_in_nor not_1bit_in_nor_1 (b_n, b);
nor nor0 (out, a_n, b_n);

endmodule