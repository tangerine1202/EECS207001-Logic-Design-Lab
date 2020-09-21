`timescale 1ns / 1ps

// TODO: rename args
module Ge_1bit(a, b, a_ge_b);
input a, b;
output a_ge_b;
wire lt;

Lt_1bit lt0 (
    .a(a),
    .b(b),
    .a_lt_b(lt)
);

not not0 (a_ge_b, a_lt_b);

endmodule
