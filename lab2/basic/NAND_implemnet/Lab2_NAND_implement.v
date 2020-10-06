`timescale 1ns/1ps

module NAND_Implement (a, b, sel, out);

input a, b;
input [3-1:0] sel;
output out;

wire [8-1:0] decoder_out;
wire out_n;

wire a_n;       // !a
wire b_n;       // !b
wire ab;        // a nand b
wire ab_n;      // !(a nand b)
wire anbn;      // !a nand !b
wire anbn_n;    // !(!a nand !b)
wire ab_anbn;   // (a nand b) nand (!a nand !b)
wire ab_anbn_n; // !((a nand b) nand (!a nand !b))

wire w_not_n;
wire w_nor_n;
wire w_and_n;
wire w_or_n;
wire w_xor_n;
wire w_xnor_n;
wire w_nand0_n;
wire w_nand1_n;


// TODO: Improve performance by input in to decoder.
NAND_Decoder_3x8 decoder_3x8_0 (
  .out(decoder_out[8-1:0]),
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
nand nand0 (w_not_n, decoder_out[0], a_n);

// nor
// equal anbn_n
nand nand1 (w_nor_n, decoder_out[1], anbn_n);

// and
// equal ab_n
nand nand2 (w_and_n, decoder_out[2], ab_n);

// or
// equal anbn
nand nand3 (w_or_n, decoder_out[3], anbn);

// xor
// equal ab_anbn_n
nand nand4 (w_xor_n, decoder_out[4], ab_anbn_n);

// xnor
// equal ab_anbn
nand nand5 (w_xnor_n, decoder_out[5], ab_anbn);

// nand
// equal ab
nand nand6 (w_nand0_n, decoder_out[6], ab);
nand nand7 (w_nand1_n, decoder_out[7], ab);

// or
nand nand8 (out, w_not_n, w_nor_n, w_and_n, w_or_n, w_xor_n, w_xnor_n, w_nand0_n, w_nand1_n);


endmodule



