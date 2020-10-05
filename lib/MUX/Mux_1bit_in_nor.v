`timescale 1ns/1ps

module Mux_1bit_in_nor (out, in1, in0, sel);

input in0;
input in1;
input sel;
output out;

wire sel_n;
wire and_in_0;
wire and_in_1;

Not_1bit_in_nor not_1bit_in_nor_0 (sel_n, sel);
And_1bit_in_nor and_1bit_in_nor_0 (and_in_0, in0, sel_n);
And_1bit_in_nor and_1bit_in_nor_1 (and_in_1, in1, sel);
Or_1bit_in_nor  or_1bit_in_nor_0  (out, and_in_0, and_in_1);

endmodule