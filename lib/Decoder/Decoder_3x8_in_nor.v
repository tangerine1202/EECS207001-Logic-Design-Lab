`timescale 1ns/1ps

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