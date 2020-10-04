`timescale 1ns/1ps

module Flip_Flop (clk, d, q);
input clk;
input d;
output q;

wire clk_n;
wire q_master;

not not0 (clk_n, clk);

Latch Master (
  .clk (clk),
  .d (d),
  .q (q_master)
);

Latch Slave (
  .clk (clk_n),
  .d (q_master),
  .q (q)
);

endmodule

module Latch (clk, d, q);

input clk;
input d;
output q;

wire d_n;
wire q_n;
wire w0;
wire w1;

not not0 (d_n, d);
nand nand0 (w0, clk, d);
nand nand1 (w1, clk, d_n);
nand nand2 (q, w0, q_n);
nand nand3 (q_n, w1, q);

endmodule
