`timescale 1ns/1ps

module Decoder_n_4x16_in_nand (out, sel);

parameter SIZE_IN = 4;
parameter SIZE_OUT = 16;

input [SIZE_IN-1:0] sel;
output [SIZE_OUT-1:0] out;

wire [SIZE_IN-1:0] sel_n;
wire [SIZE_OUT-1:0] out_n;

nand sel_n_0 (sel_n[0], sel[0], sel[0]);
nand sel_n_1 (sel_n[1], sel[1], sel[1]);
nand sel_n_2 (sel_n[2], sel[2], sel[2]);
nand sel_n_3 (sel_n[3], sel[3], sel[3]);

nand nand0 (out[0], sel_n[0], sel_n[1], sel_n[2], sel_n[3]);
nand nand1 (out[1], sel[0], sel_n[1], sel_n[2], sel_n[3]);
nand nand2 (out[2], sel_n[0], sel[1], sel_n[2], sel_n[3]);
nand nand3 (out[3], sel[0], sel[1], sel_n[2], sel_n[3]);
nand nand4 (out[4], sel_n[0], sel_n[1], sel[2], sel_n[3]);
nand nand5 (out[5], sel[0], sel_n[1], sel[2], sel_n[3]);
nand nand6 (out[6], sel_n[0], sel[1], sel[2], sel_n[3]);
nand nand7 (out[7], sel[0], sel[1], sel[2], sel_n[3]);
nand nand8 (out[8], sel_n[0], sel_n[1], sel_n[2], sel[3]);
nand nand9 (out[9], sel[0], sel_n[1], sel_n[2], sel[3]);
nand nand10 (out[10], sel_n[0], sel[1], sel_n[2], sel[3]);
nand nand11 (out[11], sel[0], sel[1], sel_n[2], sel[3]);
nand nand12 (out[12], sel_n[0], sel_n[1], sel[2], sel[3]);
nand nand13 (out[13], sel[0], sel_n[1], sel[2], sel[3]);
nand nand14 (out[14], sel_n[0], sel[1], sel[2], sel[3]);
nand nand15 (out[15], sel[0], sel[1], sel[2], sel[3]);

endmodule