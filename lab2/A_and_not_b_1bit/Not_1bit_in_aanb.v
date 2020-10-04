`timescale 1ns/1ps

module Not_1bit_in_aanb (out, a);
input a;
output out;

A_and_not_b_1bit aanb0 (out, 1, a);

endmodule