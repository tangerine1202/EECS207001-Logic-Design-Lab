`timescale 1ns/1ps

module Nxor_1bit (out, a, b);

input a;
input b;
output out;

wire x1;
wire x2;

nor nor0 (x1, a, b);
and and0 (x2, a, b);
or  or0  (out, x1, x2);

endmodule