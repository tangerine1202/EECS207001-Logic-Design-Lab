`timescale 1ns/1ps

// TODO: rename args
module Gt_1bit (a, b, a_gt_b);
input a, b;
output a_gt_b;
wire inv_b;

not not0 (inv_b, b);
and and0 (a_gt_b, a, inv_b);

endmodule;