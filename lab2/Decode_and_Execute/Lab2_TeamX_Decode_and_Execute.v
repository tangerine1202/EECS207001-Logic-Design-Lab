`timescale 1ns/1ps

module Decode_and_Execute (op_code, rs, rt, rd);

input [3-1:0] op_code;
input [4-1:0] rs, rt;
output [4-1:0] rd;

wire [4-1:0] out_add;
wire [4-1:0] out_sub;
wire [4-1:0] out_inc;
wire [4-1:0] out_bitwise_nor;
wire [4-1:0] out_bitwise_nand;
wire [4-1:0] out_rsdiv4;
wire [4-1:0] out_rsmul2;
wire [4-1:0] out_mul;

wire [8-1:0] out_dec;
wire [4-1:0] and_out_add;
wire [4-1:0] and_out_sub;
wire [4-1:0] and_out_inc;
wire [4-1:0] and_out_bitwise_nor;
wire [4-1:0] and_out_bitwise_nand;
wire [4-1:0] and_out_rsdiv4;
wire [4-1:0] and_out_rsmul2;
wire [4-1:0] and_out_mul;

ADD add_0 (
  .in0(rs),
  .in1(rt),
  .out(out_add)
);

SUB sub_0 (
  .in0(rs),
  .in1(rt),
  .out(out_sub)
);

INC inc_0 (
  .in(rs),
  .out(out_inc)
);

Bitwise_Nor bitwise_nor_0 (
  .in0(rs),
  .in1(rt),
  .out(out_bitwise_nor)
);

Bitwise_Nand bitwise_nand_0 (
  .in0(rs),
  .in1(rt),
  .out(out_bitwise_nand)
);

RsDiv4 rsdiv4_0 (
  .in(rs),
  .out(out_rsdiv4)
);

RsMul2 rsmul2_0 (
  .in(rs),
  .out(out_rsmul2)
);

MUL mul_0 (
  .in0(rs),
  .in1(rt),
  .out(out_mul)
);


Decoder_3x8_in_nor dec_3x8_in_nor (
  .out(out_dec),
  .sel(op_code)
);


And_4bits_fanout and_4bits_fanout_0 (.out(and_out_add), .in(out_add), .fan(out_dec[0]));
And_4bits_fanout and_4bits_fanout_1 (.out(and_out_sub), .in(out_sub), .fan(out_dec[1]));
And_4bits_fanout and_4bits_fanout_2 (.out(and_out_inc), .in(out_inc), .fan(out_dec[2]));
And_4bits_fanout and_4bits_fanout_3 (.out(and_out_bitwise_nor), .in(out_bitwise_nor), .fan(out_dec[3]));
And_4bits_fanout and_4bits_fanout_4 (.out(and_out_bitwise_nand), .in(out_bitwise_nand), .fan(out_dec[4]));
And_4bits_fanout and_4bits_fanout_5 (.out(and_out_rsdiv4), .in(out_rsdiv4), .fan(out_dec[5]));
And_4bits_fanout and_4bits_fanout_6 (.out(and_out_rsmul2), .in(out_rsmul2), .fan(out_dec[6]));
And_4bits_fanout and_4bits_fanout_7 (.out(and_out_mul), .in(out_mul), .fan(out_dec[7]));

Or_4x8_4bits_in_nor or_4x8_4bits_in_nor_0 (rd, {and_out_add, and_out_sub, and_out_inc, and_out_bitwise_nor, and_out_bitwise_nand, and_out_rsdiv4, and_out_rsmul2, and_out_mul});

endmodule

module And_4bits_fanout(out, in, fan);
input [4-1:0] in;
input fan;
output [4-1:0] out;

wire fan_n;
wire [4-1:0] fanout;

Not_1bit_in_nor not_1bit_in_nor_0 (fan_n, fan);
Not_1bit_in_nor not_1bit_in_nor_1 (fanout[0], fan_n);
Not_1bit_in_nor not_1bit_in_nor_2 (fanout[1], fan_n);
Not_1bit_in_nor not_1bit_in_nor_3 (fanout[2], fan_n);
Not_1bit_in_nor not_1bit_in_nor_4 (fanout[3], fan_n);
And_1bit_in_nor and_1bit_in_nor_0 [4-1:0] (out, in, fanout);

endmodule

module ADD (out, in0, in1);

input [4-1:0] in0;
input [4-1:0] in1;
output [4-1:0] out;

wire dummy_cout;
wire const_zero;
wire in0_0_n;

nor in0_0_n_0 (in0_0_n, in0[0], in0[0]);
nor const_zero_0 (const_zero, in0[0], in0_0_n);

FullAdder_4bits_in_nor fa_4bits_in_nor (
  .sum(out),
  .cout(dummy_cout),
  .a(in0),
  .b(in1),
  .cin(const_zero)
);

endmodule


module SUB (out, in0, in1);

input [4-1:0] in0;
input [4-1:0] in1;
output [4-1:0] out;

wire [4-1:0] in1_2sComplemnt;


Two_complement in1_2sComplemnt_0 (
  .in(in1),
  .out(in1_2sComplemnt)
);

ADD add_2sComplement (
  .in0(in0),
  .in1(in1_2sComplemnt),
  .out(out)
);

endmodule


module Two_complement (out, in);

input [4-1:0] in;
output [4-1:0] out;

wire [4-1:0] in_n;

nor in_n_0 [4-1:0] (in_n, in, in);

INC out_0 (
  .in(in_n),
  .out(out)
);

endmodule


module INC (out, in);

input [4-1:0] in;
output [4-1:0] out;

wire [4-1:0] inc_one;
wire in0_n;               // in[0]_n
wire const_zero;

nor in0_n_0 (in0_n, in[0], in[0]);
nor const_zero_0 (const_zero, in[0], in0_n);

// To improve performance, direct generate const one on output
nor inc_one_0 (inc_one[0], const_zero, const_zero);
// To improve performance, direct generate const zero on output
nor inc_one_1 [3-1:0] (inc_one[3:1], in[0], in0_n);

ADD add_0 (
  .in0(in),
  .in1(inc_one),
  .out(out)
);

endmodule

module Bitwise_Nor (out, in0, in1);

input [4-1:0] in0;
input [4-1:0] in1;
output [4-1:0] out;


nor bitwise_nor [4-1:0] (out, in0, in1);

endmodule


module Bitwise_Nand (out, in0, in1);

input [4-1:0] in0;
input [4-1:0] in1;
output [4-1:0] out;

Nand_1bit_in_nor bitwise_nand [4-1:0] (
  .in0(in0),
  .in1(in1),
  .out(out)
);

endmodule


module Nand_1bit_in_nor (out, in0, in1);

input in0;
input in1;
output out;

wire in0_n;
wire in1_n;
wire out_n;


nor in0_n_0 (in0_n, in0, in0);
nor in1_n_0 (in1_n, in1, in1);

nor out_n_0 (out_n, in0_n, in1_n);
nor out_0 (out, out_n, out_n);

endmodule


module RsDiv4 (out, in);

parameter 4 = 4;

input [4-1:0] in;
output [4-1:0] out;

wire [4-1:0] in_n;

nor in_n_0 [4-1:0] (in_n, in, in);

nor out_0 (out[0], in_n[2], in_n[2]);   // in_n[2]
nor out_1 (out[1], in_n[3], in_n[3]);   // in_n[3]
nor out_2 (out[2], in[0], in_n[0]);     // zero
nor out_3 (out[3], in[0], in_n[0]);     // zero

endmodule


module RsMul2 (out, in);

input [4-1:0] in;
output [4-1:0] out;

// in[3] didn't used, so -1
wire [4-1-1:0] in_n;

// in[3] didn't used, so -1
nor in_n_0 [4-1-1:0] (in_n, in[4-1-1:0], in[4-1-1:0]);

nor out_0 (out[0], in[0], in_n[0]);     // zero
nor out_1 (out[1], in_n[0], in_n[0]);   // in_n[0]
nor out_2 (out[2], in_n[1], in_n[1]);   // in_n[1]
nor out_3 (out[3], in_n[2], in_n[2]);   // in_n[2]

endmodule


module MUL (out, in0, in1);

input [4-1:0] in0;
input [4-1:0] in1;
output [4-1:0] out;

Multiplier_4x4_4bits_in_nor mul_4x4_4bits_in_nor (
  .out(out),
  .a(in0),
  .b(in1)
);

endmodule

module Decoder_3x8_in_nor (out, sel);

input [3-1:0] sel;
output [8-1:0] out;

wire [3-1:0] sel_n;

Not_1bit_in_nor not_1bit_in_nor_0 (sel_n[0], sel[0]);
Not_1bit_in_nor not_1bit_in_nor_1 (sel_n[1], sel[1]);
Not_1bit_in_nor not_1bit_in_nor_2 (sel_n[2], sel[2]);

And_3bits_in_nor And_3bits_in_nor_0 (out[0], sel_n[2], sel_n[1], sel_n[0]);
And_3bits_in_nor And_3bits_in_nor_1 (out[1], sel_n[2], sel_n[1], sel[0]);
And_3bits_in_nor And_3bits_in_nor_2 (out[2], sel_n[2], sel[1], sel_n[0]);
And_3bits_in_nor And_3bits_in_nor_3 (out[3], sel_n[2], sel[1], sel[0]);
And_3bits_in_nor And_3bits_in_nor_4 (out[4], sel[2], sel_n[1], sel_n[0]);
And_3bits_in_nor And_3bits_in_nor_5 (out[5], sel[2], sel_n[1], sel[0]);
And_3bits_in_nor And_3bits_in_nor_6 (out[6], sel[2], sel[1], sel_n[0]);
And_3bits_in_nor And_3bits_in_nor_7 (out[7], sel[2], sel[1], sel[0]);

endmodule

module Or_4x8_4bits_in_nor (out, a);
input [32-1:0] a;
output [4-1:0] out;

wire [4-1:0] out_n;

nor nor0 (out_n[0], a[0], a[0+4], a[0+8], a[0+12], a[0+16], a[0+20], a[0+24], a[0+28]);
nor nor1 (out_n[1], a[1], a[1+4], a[1+8], a[1+12], a[1+16], a[1+20], a[1+24], a[1+28]);
nor nor2 (out_n[2], a[2], a[2+4], a[2+8], a[2+12], a[2+16], a[2+20], a[2+24], a[2+28]);
nor nor3 (out_n[3], a[3], a[3+4], a[3+8], a[3+12], a[3+16], a[3+20], a[3+24], a[3+28]);
Not_1bit_in_nor not_1bit_in_nor [4-1:0] (out, out_n);

endmodule

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

wire [4-1:0] a_n;
wire [4-1:0] const_zero;

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

nor not0 [4-1:0] (a_n, a, a);
nor const_zero_0 [4-1:0] (const_zero, a, a_n);

FullAdder_4bits_in_nor fa_4bit_in_nor_0 (
    .sum({fa_a01[2], fa_a01[1], fa_a01[0], out[1]}),
    .cout(fa_a01[3]),
    .a({const_zero[0], and_a0b[3], and_a0b[2], and_a0b[1]}),
    .b(and_a1b),
    .cin(const_zero[1])
);
FullAdder_4bits_in_nor fa_4bit_in_nor_1 (
    .sum({fa_a12[2], fa_a12[1], fa_a12[0], out[2]}),
    .cout(fa_a12[3]),
    .a(fa_a01),
    .b(and_a2b),
    .cin(const_zero[2])
);
FullAdder_4bits_in_nor fa_4bit_in_nor_2 (
    .sum({dummy[2], dummy[1], dummy[0], out[3]}),
    .cout(dummy[3]),
    .a(fa_a12),
    .b(and_a3b),
    .cin(const_zero[3])
);

endmodule

module FullAdder_4bits_in_nor (sum, cout, a, b, cin);

input [4-1:0] a;
input [4-1:0] b;
input cin;
output [4-1:0] sum;
output cout;

wire [4-1-1:0] cout_propagate;

FullAdder_1bit_in_nor fa_in_nor_0 (.sum(sum[0]), .cout(cout_propagate[0]), .a(a[0]), .b(b[0]), .cin(cin));
FullAdder_1bit_in_nor fa_in_nor_1 (.sum(sum[1]), .cout(cout_propagate[1]), .a(a[1]), .b(b[1]), .cin(cout_propagate[0]));
FullAdder_1bit_in_nor fa_in_nor_2 (.sum(sum[2]), .cout(cout_propagate[2]), .a(a[2]), .b(b[2]), .cin(cout_propagate[1]));
FullAdder_1bit_in_nor fa_in_nor_3 (.sum(sum[3]), .cout(cout), .a(a[3]), .b(b[3]), .cin(cout_propagate[2]));

endmodule

module FullAdder_1bit_in_nor (sum, cout, a, b, cin);

input a;
input b;
input cin;
output sum;
output cout;

wire x1;

Xnor_1bit_in_nor xnor_1bit_in_nor_0 (x1, a, b);
Xnor_1bit_in_nor xnor_1bit_in_nor_1 (sum, x1, cin);
Mux_1bit_in_nor  mux_1bit_in_nor_0 (
    .in0(cin),
    .in1(a),
    .sel(x1),
    .out(cout)
);

endmodule

module Xnor_1bit_in_nor (out, a, b);
input a;
input b;
output out;

wire and_ab;
wire nor_ab;
wire out_n;

And_1bit_in_nor and_1bit_in_nor_0 (and_ab, a, b);
nor nor0 (nor_ab, a, b);
nor or0 (out_n, and_ab, nor_ab);
nor not0 (out, out_n, out_n);

endmodule

module Mux_1bit_in_nor (out, in1, in0, sel);

input in0;
input in1;
input sel;
output out;

wire sel_n;
wire and_in_0;
wire and_in_1;
wire out_n;

nor not0 (sel_n, sel, sel);
And_1bit_in_nor and_1bit_in_nor_0 (and_in_0, in0, sel_n);
And_1bit_in_nor and_1bit_in_nor_1 (and_in_1, in1, sel);
nor or0  (out_n, and_in_0, and_in_1);
nor not1 (out, out_n, out_n);

endmodule

module And_3bits_in_nor (out, a, b, c);
input a;
input b;
input c;
output out;

wire a_n;
wire b_n;
wire c_n;

Not_1bit_in_nor not_1bit_in_nor_0 (a_n, a);
Not_1bit_in_nor not_1bit_in_nor_1 (b_n, b);
Not_1bit_in_nor not_1bit_in_nor_2 (c_n, c);
nor nor0 (out, a_n, b_n, c_n);

endmodule

module And_1bit_in_nor (out, a, b);
input a;
input b;
output out;

wire a_n;
wire b_n;

Not_1bit_in_nor not_1bit_in_nor_0 (a_n, a);
Not_1bit_in_nor not_1bit_in_nor_1 (b_n, b);
nor nor0 (out, a_n, b_n);

endmodule

module Not_1bit_in_nor (out, a);
input a;
output out;

nor nor0 (out, a, a);

endmodule