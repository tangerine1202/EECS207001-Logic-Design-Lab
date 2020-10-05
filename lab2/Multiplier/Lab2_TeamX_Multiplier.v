`timescale 1ns/1ps

module Multiplier (a, b, p);
input [4-1:0] a, b;
output [8-1:0] p;

wire [4-1:0] and_a0b;
wire [4-1:0] and_a1b;
wire [4-1:0] and_a2b;
wire [4-1:0] and_a3b;
wire [4-1:0] fa_a01;
wire [4-1:0] fa_a12;
wire [4-1:0] fa_a23;

And_1bit_in_nor and_1bit_in_nor_00 (p[0], a[0], b[0]);
And_1bit_in_nor and_1bit_in_nor_01 (and_a0b[1], a[0], b[1]);
And_1bit_in_nor and_1bit_in_nor_02 (and_a0b[2], a[0], b[2]);
And_1bit_in_nor and_1bit_in_nor_03 (and_a0b[3], a[0], b[3]);

And_1bit_in_nor and_1bit_in_nor_13 (and_a1b[0], a[1], b[0]);
And_1bit_in_nor and_1bit_in_nor_13 (and_a1b[1], a[1], b[1]);
And_1bit_in_nor and_1bit_in_nor_13 (and_a1b[2], a[1], b[2]);
And_1bit_in_nor and_1bit_in_nor_13 (and_a1b[3], a[1], b[3]);

And_1bit_in_nor and_1bit_in_nor_23 (and_a2b[0], a[2], b[0]);
And_1bit_in_nor and_1bit_in_nor_23 (and_a2b[1], a[2], b[1]);
And_1bit_in_nor and_1bit_in_nor_23 (and_a2b[2], a[2], b[2]);
And_1bit_in_nor and_1bit_in_nor_23 (and_a2b[3], a[2], b[3]);

And_1bit_in_nor and_1bit_in_nor_33 (and_a3b[0], a[3], b[0]);
And_1bit_in_nor and_1bit_in_nor_33 (and_a3b[1], a[3], b[1]);
And_1bit_in_nor and_1bit_in_nor_33 (and_a3b[2], a[3], b[2]);
And_1bit_in_nor and_1bit_in_nor_33 (and_a3b[3], a[3], b[3]);

// TODO: check whether p[1] connects to sum[0] in 4-bit fa
FullAdder_4bit_in_nor fa_4bit_in_nor_0 (
    .sum({p[1], fa_a01[0], fa_a01[1], fa_a01[2]}),
    .cout(fa_a01[3]),
    .a({and_a0b[1], and_a0b[2], and_a0b[3], 1'b0}),
    .b(and_a1b),
    .cin(1'b0)
};
FullAdder_4bit_in_nor fa_4bit_in_nor_1 (
    .sum({p[2], fa_a12[0], fa_a12[1], fa_a12[2]}),
    .cout(fa_a12[3]),
    .a(fa_a01),
    .b(and_a2b),
    .cin(1'b0)
};
FullAdder_4bit_in_nor fa_4bit_in_nor_1 (
    .sum({p[3], p[4], p[5], p[6]}),
    .cout(p[7]),
    .a(fa_a12),
    .b(and_a3b),
    .cin(1'b0)
};

endmodule