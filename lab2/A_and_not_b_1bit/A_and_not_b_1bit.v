`timescale 1ns/1ps

module A_and_not_b_1bit (out, a, b);
input a;
input b;
output out;

wire b_n;

not not0 (b_n, b);
and and0 (out, a, b_n);

endmodule