`timescale 1ns/1ps

module FullAdder_4bits_in_nor (sum, cout, a, b, cin);

parameter SIZE = 4;

input [SIZE-1:0] a;
input [SIZE-1:0] b;
input cin;
output [SIZE-1:0] sum;
output cout;

wire [SIZE-1-1:0] cout_propagate;

FullAdder_1bit_in_nor fa_in_nor_0 (sum[0], cout_propagate[0], a[0], b[0], cin);
FullAdder_1bit_in_nor fa_in_nor_1 (sum[1], cout_propagate[1], a[1], b[1], cout_propagate[0]);
FullAdder_1bit_in_nor fa_in_nor_1 (sum[2], cout_propagate[2], a[2], b[2], cout_propagate[1]);
FullAdder_1bit_in_nor fa_in_nor_1 (sum[3], cout, a[3], b[3], cout_propagate[2]);

endmodule
