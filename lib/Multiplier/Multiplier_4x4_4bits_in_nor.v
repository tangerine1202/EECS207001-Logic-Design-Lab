`timescale 1ns/1ps

module Multiplier_4x4_4bits_in_nor (out, a, b);
input [4-1:0] a, b;
output [4-1:0] out;

wire [4-1:0] and_a0b;
wire [4-1:0] and_a1b;
wire [4-1:0] and_a2b;
wire [4-1:0] and_a3b;
wire [4-1:0] fa_a01;
wire [4-1:0] fa_a12;
wire [4-1:0] fa_a23;
wire [4-1:0] dummy;

And_1bit_in_nor and_1bit_in_nor_00 (out[0], a[0], b[0]);
And_1bit_in_nor and_1bit_in_nor_01 (and_a0b[1], a[0], b[1]);
And_1bit_in_nor and_1bit_in_nor_02 (and_a0b[2], a[0], b[2]);
And_1bit_in_nor and_1bit_in_nor_03 (and_a0b[3], a[0], b[3]);

And_1bit_in_nor and_1bit_in_nor_10 (and_a1b[0], a[1], b[0]);
And_1bit_in_nor and_1bit_in_nor_11 (and_a1b[1], a[1], b[1]);
And_1bit_in_nor and_1bit_in_nor_12 (and_a1b[2], a[1], b[2]);
And_1bit_in_nor and_1bit_in_nor_13 (and_a1b[3], a[1], b[3]);

And_1bit_in_nor and_1bit_in_nor_20 (and_a2b[0], a[2], b[0]);
And_1bit_in_nor and_1bit_in_nor_21 (and_a2b[1], a[2], b[1]);
And_1bit_in_nor and_1bit_in_nor_22 (and_a2b[2], a[2], b[2]);
And_1bit_in_nor and_1bit_in_nor_23 (and_a2b[3], a[2], b[3]);

And_1bit_in_nor and_1bit_in_nor_30 (and_a3b[0], a[3], b[0]);
And_1bit_in_nor and_1bit_in_nor_31 (and_a3b[1], a[3], b[1]);
And_1bit_in_nor and_1bit_in_nor_32 (and_a3b[2], a[3], b[2]);
And_1bit_in_nor and_1bit_in_nor_33 (and_a3b[3], a[3], b[3]);

FullAdder_4bits_in_nor fa_4bit_in_nor_0 (
    .sum({fa_a01[2], fa_a01[1], fa_a01[0], out[1]}),
    .cout(fa_a01[3]),
    .a({1'b0, and_a0b[3], and_a0b[2], and_a0b[1]}),
    .b(and_a1b),
    .cin(1'b0)
);
FullAdder_4bits_in_nor fa_4bit_in_nor_1 (
    .sum({fa_a12[2], fa_a12[1], fa_a12[0], out[2]}),
    .cout(fa_a12[3]),
    .a(fa_a01),
    .b(and_a2b),
    .cin(1'b0)
);
FullAdder_4bits_in_nor fa_4bit_in_nor_2 (
    .sum({dummy[2], dummy[1], dummy[0], out[3]}),
    .cout(out[3]),
    .a(fa_a12),
    .b(and_a3b),
    .cin(1'b0)
);

endmodule
