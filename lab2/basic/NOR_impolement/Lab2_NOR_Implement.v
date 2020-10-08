`timescale 1ns/1ps

module NOR_Implement (a, b, sel, out);
input a, b;
input [3-1:0] sel;
output out;

wire w_not;
wire w_nor;
wire w_and;
wire w_or;
wire w_xor;
wire w_xnor;
wire w_nand0;
wire w_nand1;
wire [8-1:0] w_decs;
wire [8-1:0] w_ands;

Not_in_nor not0 (w_not, a);
Nor_in_nor nor0 (w_nor, a, b);
And_in_nor and0 (w_and, a, b);
Or_in_nor or0 (w_or, a, b);
Xor_in_nor xor0 (w_xor, a, b);
Xnor_in_nor xnor0 (w_xnor, a, b);
Nand_in_nor nand0 (w_nand0, a, b);
Nand_in_nor nand1 (w_nand1, a, b);

Decoder_3x8_in_nor decoder_3x8_0 (w_decs, sel);

And_in_nor ands0 (w_ands[0], w_decs[0], w_not);
And_in_nor ands1 (w_ands[1], w_decs[1], w_nor);
And_in_nor ands2 (w_ands[2], w_decs[2], w_and);
And_in_nor ands3 (w_ands[3], w_decs[3], w_or);
And_in_nor ands4 (w_ands[4], w_decs[4], w_xor);
And_in_nor ands5 (w_ands[5], w_decs[5], w_xnor);
And_in_nor ands6 (w_ands[6], w_decs[6], w_nand0);
And_in_nor ands7 (w_ands[7], w_decs[7], w_nand1);

Or_8x1_in_nor or_8x1_0 (out, w_ands);

endmodule


module Decoder_3x8_in_nor (out, sel);

input [3-1:0] sel;
output [8-1:0] out;

wire [3-1:0] sel_n;

Not_in_nor not0 [3-1:0] (sel_n, sel);

And_3bits_in_nor and0 (out[0], sel_n[2], sel_n[1], sel_n[0]);
And_3bits_in_nor and1 (out[1], sel_n[2], sel_n[1], sel[0]);
And_3bits_in_nor and2 (out[2], sel_n[2], sel[1], sel_n[0]);
And_3bits_in_nor and3 (out[3], sel_n[2], sel[1], sel[0]);
And_3bits_in_nor and4 (out[4], sel[2], sel_n[1], sel_n[0]);
And_3bits_in_nor and5 (out[5], sel[2], sel_n[1], sel[0]);
And_3bits_in_nor and6 (out[6], sel[2], sel[1], sel_n[0]);
And_3bits_in_nor and7 (out[7], sel[2], sel[1], sel[0]);

endmodule


module Or_8x1_in_nor (out, in);

input [8-1:0] in;
output out;

wire or_n;

nor nor_7x1 (or_n, in[0], in[1], in[2], in[3], in[4], in[5], in[6], in[7]);
nor nor_out (out, or_n, or_n);

endmodule


module Not_in_nor (out, in);

input in;
output out;

nor nor0 (out, in, in);

endmodule


module Or_in_nor (out, in0, in1);

input in0;
input in1;
output out;

wire or_n;

nor nor0 (or_n, in0, in1);
nor nor1 (out, or_n, or_n);

endmodule

module And_3bits_in_nor (out, in0, in1, in2);

input in0;
input in1;
input in2;
output out;

wire in0_n;
wire in1_n;
wire in2_n;

nor nor0 (in0_n, in0, in0);
nor nor1 (in1_n, in1, in1);
nor nor2 (in2_n, in2, in2);
nor nor3 (out, in0_n, in1_n, in2_n);

endmodule

module And_in_nor (out, in0, in1);

input in0;
input in1;
output out;

wire in0_n;
wire in1_n;

nor nor0 (in0_n, in0, in0);
nor nor1 (in1_n, in1, in1);
nor nor2 (out, in0_n, in1_n);

endmodule


module Nand_in_nor (out, in0, in1);

input in0;
input in1;
output out;

wire in0_n;
wire in1_n;
wire w0;

nor nor0 (in0_n, in0, in0);
nor nor1 (in1_n, in1, in1);
nor nor2 (w0, in0_n, in1_n);
nor nor3 (out, w0, w0);

endmodule


module Xnor_in_nor (out, in0, in1);

input in0;
input in1;
output out;

wire w0;
wire w1;
wire w2;

nor nor0 (w0, in0, in1);
nor nor1 (w1, w0, in0);
nor nor2 (w2, w0, in1);
nor nor3 (out, w1, w1);

endmodule


module Xor_in_nor (out, in0, in1);

input in0;
input in1;
output out;

wire in0_n;
wire in1_n;
wire w0;
wire w1;

nor nor0 (in0_n, in0, in0);
nor nor1 (in1_n, in1, in1);
nor nor2 (w0, in0_n, in1_n);
nor nor3 (w1, in0, in1);
nor nor4 (out, w0, w1);

endmodule


module Nor_in_nor (out, in0, in1);

input in0;
input in1;
output out;

nor nor0 (out, in0, in1);

endmodule

