`timescale 1ns/1ps

module Le_1bit(out, a, b);
input a, b;
output out;
wire gt;

Gt_1bit gt0 (
    .a(a),
    .b(b),
    .out(gt)
);

not not0 (out, gt);

endmodule
