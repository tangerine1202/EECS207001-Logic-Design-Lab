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

wire [4-1:0] a_n;
wire [4-1:0] const_zero;

And_1bit_in_nor and_1bit_in_nor_00 (p[0], a[0], b[0]);
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

nor a_n [4-1:0] (a_n, a, a);
nor const_zero_0 [4-1:0] (const_zero, a, a_n);

FullAdder_4bits_in_nor fa_4bit_in_nor_0 (
    .sum({fa_a01[2], fa_a01[1], fa_a01[0], p[1]}),
    .cout(fa_a01[3]),
    .a({const_zero[0], and_a0b[3], and_a0b[2], and_a0b[1]}),
    .b(and_a1b),
    .cin(const_zero[1])
);
FullAdder_4bits_in_nor fa_4bit_in_nor_1 (
    .sum({fa_a12[2], fa_a12[1], fa_a12[0], p[2]}),
    .cout(fa_a12[3]),
    .a(fa_a01),
    .b(and_a2b),
    .cin(const_zero[2])
);
FullAdder_4bits_in_nor fa_4bit_in_nor_2 (
    .sum({p[6], p[5], p[4], p[3]}),
    .cout(p[7]),
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

module And_1bit_in_nor (out, a, b);
input a;
input b;
output out;

wire a_n;
wire b_n;

nor not0 (a_n, a, a);
nor not1 (b_n, b, b);
nor nor0 (out, a_n, b_n);

endmodule