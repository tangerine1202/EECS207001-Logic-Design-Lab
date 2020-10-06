`timescale 1ns/1ps

module FullAdder_4bits_in_nor (sum, cout, a, b, cin);

parameter SIZE = 4;

input [SIZE-1:0] a;
input [SIZE-1:0] b;
input cin;
output [SIZE-1:0] sum;
output cout;

wire [SIZE-1-1:0] cout_propagate;

FullAdder_1bit_in_nor fa_in_nor_0 (.sum(sum[0]), .cout(cout_propagate[0]), .a(a[0]), .b(b[0]), .cin(cin));
FullAdder_1bit_in_nor fa_in_nor_1 (.sum(sum[1]), .cout(cout_propagate[1]), .a(a[1]), .b(b[1]), .cin(cout_propagate[0]));
FullAdder_1bit_in_nor fa_in_nor_2 (.sum(sum[2]), .cout(cout_propagate[2]), .a(a[2]), .b(b[2]), .cin(cout_propagate[1]));
FullAdder_1bit_in_nor fa_in_nor_3 (.sum(sum[3]), .cout(cout), .a(a[3]), .b(b[3]), .cin(cout_propagate[2]));

endmodule
