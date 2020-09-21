`timescale 1ns / 1ps

// TODO: rename args
module Le_1bit(a, b, a_le_b);
input a, b;
output a_le_b;
wire gt;

Gt_1bit gt0 (
    .a(a),
    .b(b),
    .a_gt_b(gt)
);

not not0 (a_le_b, a_gt_b);

endmodule
