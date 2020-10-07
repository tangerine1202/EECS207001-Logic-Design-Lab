`timescale 1ns/1ps

module And_3bits_in_nor (out, a, b, c);
input a;
input b;
input c;
output out;

wire a_n;
wire b_n;
wire c_n;

Not_1bit_in_nor not_1bit_in_nor_0 (a_n, a);
Not_1bit_in_nor not_1bit_in_nor_1 (b_n, b);
Not_1bit_in_nor not_1bit_in_nor_2 (c_n, c);
nor nor0 (out, a_n, b_n, c_n);

endmodule