`timescale 1ns/1ps

module Gt_1bit (out, a, b);
input a, b;
output out;
wire b_n;

not not0 (b_n, b);
and and0 (out, a, b_n);

endmodule