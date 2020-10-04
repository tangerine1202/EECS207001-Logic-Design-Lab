`timescale 1ns/1ps

module NAND_Implement (a, b, sel, out);
input a, b;
input [3-1:0] sel;
output out;

wire decoder_out[7:0];
wire out_n;

wire a_n;       // !a
wire b_n;       // !b
wire ab;        // a nand b
wire ab_n;      // !(a nand b)
wire anbn;      // !a nand !b
wire anbn_n;    // !(!a nand !b)
wire ab_anbn;   // (a nand b) nand (!a nand !b)
wire ab_anbn_n; // !((a nand b) nand (!a nand !b))

wire w_not;
wire w_nor;
wire w_and;
wire w_or;
wire w_xor;
wire w_xnor;
wire w_nand0;
wire w_nand1;


// TODO: Improve performance by input in to decoder.
NAND_Decoder_3x8 decoder_3x8_0 (
  .out(decoder_out[7:0]),
  .sel(sel[3-1:0])
);

nand not_a            (a_n, a, a);
nand not_b            (b_n, b, b);
nand nand_ab          (ab, a, b);
nand nand_anbn        (anbn, a_n, b_n);
nand nand_ab_anbn     (ab_anbn, ab, anbn);
nand not_ab           (ab_n, ab, ab);
nand not_anbn         (anbn_n, anbn, anbn);
nand not_ab_anbn      (ab_anbn_n, ab_anbn, ab_anbn);

// not
// equal a_n
nand nand0 (w_not, decoder_out[0], a_n);

// nor
// equal anbn_n
nand nand1 (w_nor, decoder_out[1], anbn_n);

// and
// equal ab_n
nand nand2 (w_and, decoder_out[2], ab_n);

// or
// equal anbn
nand nand3 (w_or, decoder_out[3], anbn);

// xor
// equal ab_anbn_n
nand nand4 (w_xor, decoder_out[4], ab_anbn_n);

// xnor
// equal ab_anbn
nand nand5 (w_xnor, decoder_out[5], ab_anbn);

// nand
// equal ab
nand nand6 (w_nand0, decoder_out[6], ab);
nand nand7 (w_nand1, decoder_out[7], ab);

// or
nand nand8 (out_n, w_not, w_nor, w_and, w_or, w_xor, w_xnor, w_nand0, wnan1);

// out
nand nand9 (out, out_n, out_n);


endmodule



