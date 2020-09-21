`timescale 1ns/1ps

// TODO: rename args
module Lt_1bit (a, b, a_lt_b);
input a, b;
output a_lt_b;
wire inv_a;

not not0 (inv_a, a);
and and0 (a_lt_b, inv_a, b);

endmodule;