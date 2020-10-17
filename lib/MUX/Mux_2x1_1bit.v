`timescale 1ns/1ps

module Mux_1bit (out, in1, in0, sel);

input in0;
input in1;
input sel;
output out;

wire sel_n;
wire and_in_0;
wire and_in_1;

not not0 (sel_n, sel);
and and0 (and_in_0, in0, sel_n);
and and1 (and_in_1, in1, sel);
or  or0  (out, and_in_1, and_in_0);

endmodule
