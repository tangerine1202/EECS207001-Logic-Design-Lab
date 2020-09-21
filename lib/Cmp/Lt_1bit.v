`timescale 1ns/1ps

module Lt_1bit (out, a, b);
input a, b;
output out;
wire a_n;

not not0 (a_n, a);
and and0 (out, a_n, b);

endmodule