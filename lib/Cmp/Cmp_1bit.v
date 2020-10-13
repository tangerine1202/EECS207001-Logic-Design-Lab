module Cmp_1bit(gt, eq, lt, a, b, gt_up, eq_up, lt_up);

input a;
input b;
input gt_up;
input eq_up;
input lt_up;
output gt;
output eq;
output lt;

wire a_n;
wire b_n;
wire gt_cur;
wire eq_cur;
wire lt_cur;

not (b_n, b);
and (gt_cur, a, b_n)
or (gt, gt_cur, gt_up)

xnor (eq_cur, a, b)
and (eq, eq_cur, eq_up)

not (a_n, a);
and (lt_cur, a_n, b)
or (lt, lt_cur, lt_up)

endmodule