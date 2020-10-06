`timescale 1ns/1ps

module NAND_Decoder_3x8 (out, sel);

parameter SIZE_IN = 3;
parameter SIZE_OUT = 8;

input [SIZE_IN-1:0] sel;
output [SIZE_OUT-1:0] out;

wire [SIZE_IN-1:0] sel_n;
wire [SIZE_OUT-1:0] out_n;

nand nand0 (sel_n[0], sel[0], sel[0]);
nand nand1 (sel_n[1], sel[1], sel[1]);
nand nand2 (sel_n[2], sel[2], sel[2]);

nand nand3 (out_n[0], sel_n[2], sel_n[1], sel_n[0]);
nand nand4 (out_n[1], sel_n[2], sel_n[1], sel[0]);
nand nand5 (out_n[2], sel_n[2], sel[1], sel_n[0]);
nand nand6 (out_n[3], sel_n[2], sel[1], sel[0]);
nand nand7 (out_n[4], sel[2], sel_n[1], sel_n[0]);
nand nand8 (out_n[5], sel[2], sel_n[1], sel[0]);
nand nand9 (out_n[6], sel[2], sel[1], sel_n[0]);
nand nand10 (out_n[7], sel[2], sel[1], sel[0]);

nand nand11 (out[0], out_n[0], out_n[0]);
nand nand12 (out[1], out_n[1], out_n[1]);
nand nand13 (out[2], out_n[2], out_n[2]);
nand nand14 (out[3], out_n[3], out_n[3]);
nand nand15 (out[4], out_n[4], out_n[4]);
nand nand16 (out[5], out_n[5], out_n[5]);
nand nand17 (out[6], out_n[6], out_n[6]);
nand nand18 (out[7], out_n[7], out_n[7]);

endmodule