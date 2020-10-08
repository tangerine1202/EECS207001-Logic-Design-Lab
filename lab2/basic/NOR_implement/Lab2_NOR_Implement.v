`timescale 1ns/1ps

module NOR_Implement (a, b, sel, out);
input a, b;
input [3-1:0] sel;
output out;

wire [3-1:0] sel_n;

wire not_a;
wire nor_ab;
wire and_ab;
wire or_ab;
wire xor_ab;
wire xnor_ab;
wire nand_ab;

wire not_out;
wire nor_out;
wire and_out;
wire or_out;
wire xor_out;
wire xnor_out;
wire nand_out;

wire const_zero;
wire const_one;

Not_in_nor sel_n_0 (sel_n[0], sel[0]);
Not_in_nor sel_n_1 (sel_n[1], sel[1]);
Not_in_nor sel_n_2 (sel_n[2], sel[2]);

Not_in_nor not_in_nor_0 (not_a, a);
nor nor0 (nor_ab, a, b);
And_in_nor and_in_nor_0 (and_ab, a, b);
Or_in_nor  or_in_nor_0  (or_ab, a, b);
Xor_in_nor xor_in_nor_0 (xor_ab, a, b);
Xnor_in_nor xnor_in_nor_0 (xnor_ab, a, b);
Nand_in_nor nor_in_nor_0 (nand_ab, a, b);

nor const_zero_0 (const_zero, a, not_a);
nor const_one_0 (const_one, const_zero, const_zero);
And_4bits_in_nor and_4bits_in_nor_0 (not_out, {sel_n[2], sel_n[1], sel_n[0], not_a});
And_4bits_in_nor and_4bits_in_nor_1 (nor_out, {sel_n[2], sel_n[1], sel[0], nor_ab});
And_4bits_in_nor and_4bits_in_nor_2 (and_out, {sel_n[2], sel[1], sel_n[0], and_ab});
And_4bits_in_nor and_4bits_in_nor_3 (or_out, {sel_n[2], sel[1], sel[0], or_ab});
And_4bits_in_nor and_4bits_in_nor_4 (xor_out, {sel[2], sel_n[1], sel_n[0], xor_ab});
And_4bits_in_nor and_4bits_in_nor_5 (xnor_out, {sel[2], sel_n[1], sel[0], xnor_ab});
And_4bits_in_nor and_4bits_in_nor_6 (nand_out, {sel[2], sel[1], const_one, nand_ab});

Or_7bits_in_nor or0 (out, {not_out, nor_out, and_out, or_out, xor_out, xnor_out, nand_out});

endmodule

// ------------------

// 7-bit OR
module Or_7bits_in_nor (out, a);

input [7-1:0] a;
output out;

wire out_n;

nor nor0 (out_n, a[0], a[1], a[2], a[3], a[4], a[5], a[6]);
Not_in_nor not_in_nor_0 (out, out_n);

endmodule

// 4-bit AND
module And_4bits_in_nor (out, a);

input [4-1:0] a;
output out;

wire [4-1:0] a_n;

Not_in_nor not_in_nor [4-1:0] (a_n, a);
nor nor0 (out, a_n[0], a_n[1], a_n[2], a_n[3]);

endmodule

// NOT
module Not_in_nor (out, a);

input a;
output out;

nor nor0 (out, a, a);

endmodule

// OR
module Or_in_nor (out, a, b);

input a;
input b;
output out;

wire out_n;

nor nor0 (out_n, a, b);
Not_in_nor not_in_nor (out, out_n);

endmodule

// AND
module And_in_nor (out, a, b);

input a;
input b;
output out;

wire a_n;
wire b_n;

Not_in_nor not_in_nor_0 (a_n, a);
Not_in_nor not_in_nor_1 (b_n, b);
nor nor0 (out, a_n, b_n);

endmodule

// XOR
module Xor_in_nor (out, a, b);

input a;
input b;
output out;

wire and_ab;
wire nor_ab;

And_in_nor and_in_nor_0 (and_ab, a, b);
nor nor0 (nor_ab, a, b);
nor nor1 (out, and_ab, nor_ab);

endmodule

// XNOR
module Xnor_in_nor (out, a, b);

input a;
input b;
output out;

wire out_n;

Xor_in_nor xor_in_nor_0 (out_n, a, b);
Not_in_nor not_in_nor_0 (out, out_n);

endmodule

// NAND
module Nand_in_nor (out, a, b);

input a;
input b;
output out;

wire out_n;

And_in_nor and_in_nor_0 (out_n, a, b);
Not_in_nor not_in_nor_0 (out, out_n);

endmodule