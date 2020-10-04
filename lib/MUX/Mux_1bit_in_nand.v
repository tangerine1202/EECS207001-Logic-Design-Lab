`timescale 1ns/1ps

module Mux_1bit_in_nand (out, in1, in0, sel);

input in0;
input in1;
input sel;
output out;

wire sel_n;
wire nand_in_0;
wire nand_in_1;

nand (sel_n, sel);
nand nand0 (nand_in_1, in1, sel);
nand nand1 (nand_in_0, in0, sel_n);
nand nand2 (out, nand_in_1, nand_in_0);

endmodule
