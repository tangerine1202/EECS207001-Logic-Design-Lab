`timescale 1ns/1ps

module Comparator_4bits (a, b, a_lt_b, a_gt_b, a_eq_b);

parameter SIZE = 4;

input [SIZE-1:0] a, b;
output a_lt_b, a_gt_b, a_eq_b;

wire [SIZE-1:0] eq, gt;
wire [SIZE-1-1:0] leading_gt;

Eq_1bit eq_0 (
  .a(a[0]),
  .b(b[0]),
  .out(eq[0])
);
Eq_1bit eq_1 (
  .a(a[1]),
  .b(b[1]),
  .out(eq[1])
);
Eq_1bit eq_2 (
  .a(a[2]),
  .b(b[2]),
  .out(eq[2])
);
Eq_1bit eq_3 (
  .a(a[3]),
  .b(b[3]),
  .out(eq[3])
);

Gt_1bit gt_0 (
  .a(a[0]),
  .b(b[0]),
  .out(gt[0])
);
Gt_1bit gt_1 (
  .a(a[1]),
  .b(b[1]),
  .out(gt[1])
);
Gt_1bit gt_2 (
  .a(a[2]),
  .b(b[2]),
  .out(gt[2])
);
Gt_1bit gt_3 (
  .a(a[3]),
  .b(b[3]),
  .out(gt[3])
);

// eq
and and_eq_0 (a_eq_b, eq[0], eq[1], eq[2], eq[3]);

// gt
and and_gt_2 (leading_gt[2], eq[3], gt[2]);
and and_gt_1 (leading_gt[1], eq[3], eq[2], gt[1]);
and and_gt_0 (leading_gt[0], eq[3], eq[2], eq[1], gt[0]);
or  or_gt_0  (a_gt_b, gt[3], leading_gt[2], leading_gt[1], leading_gt[0]);

// lt
nor nor_lt_0 (a_lt_b, a_eq_b, a_gt_b);

endmodule
