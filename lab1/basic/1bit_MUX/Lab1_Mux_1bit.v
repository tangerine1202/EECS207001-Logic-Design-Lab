`timescale 1ns/1ps

module Mux_1bit (a, b, sel, f);
input a, b;
input sel;
output f;

wire inv_sel, and_a, and_b;

not not0 (inv_sel, sel);
and and0 (and_a, a, sel);
and and1 (and_b, b, inv_sel);
or  or0  (f, and_a, and_b);

endmodule
