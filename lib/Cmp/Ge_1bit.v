`timescale 1ns / 1ps

module Ge_1bit(out, a, b);
input a, b;
output out;
wire lt;

Lt_1bit lt0 (
    .a(a),
    .b(b),
    .out(lt)
);

not not0 (out, lt);

endmodule
