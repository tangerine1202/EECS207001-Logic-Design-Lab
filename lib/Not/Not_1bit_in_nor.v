`timescale 1ns/1ps

module Not_1bit_in_nor (out, a);
input a;
output out;

nor nor0 (out, a, a);

endmodule