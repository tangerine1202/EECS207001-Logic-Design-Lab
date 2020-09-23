`timescale 1ns/1ps

module RippleCarryAdder (a, b, cin, cout, sum);

parameter SIZE = 8;

input [SIZE-1:0] a, b;
input cin;
output [SIZE-1:0] sum;
output cout;

wire [SIZE-1-1:0] out;

FullAdder fa0 (.a(a[0]), .b(b[0]), .cin(cin), .sum(sum[0]), .cout(out[0]));
FullAdder fa1 (.a(a[1]), .b(b[1]), .cin(out[0]), .sum(sum[1]), .cout(out[1]));
FullAdder fa2 (.a(a[2]), .b(b[2]), .cin(out[1]), .sum(sum[2]), .cout(out[2]));
FullAdder fa3 (.a(a[3]), .b(b[3]), .cin(out[2]), .sum(sum[3]), .cout(out[3]));
FullAdder fa4 (.a(a[4]), .b(b[4]), .cin(out[3]), .sum(sum[4]), .cout(out[4]));
FullAdder fa5 (.a(a[5]), .b(b[5]), .cin(out[4]), .sum(sum[5]), .cout(out[5]));
FullAdder fa6 (.a(a[6]), .b(b[6]), .cin(out[5]), .sum(sum[6]), .cout(out[6]));
FullAdder fa7 (.a(a[7]), .b(b[7]), .cin(out[6]), .sum(sum[7]), .cout(cout));

endmodule
