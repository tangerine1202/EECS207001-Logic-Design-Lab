`timescale 1ns/1ps

`define CYC 4

module Flip_Flop_t;
reg clk = 1'b1;
reg d = 1'b0;
wire q_f, q_l;

Flip_Flop ff (
  .clk (clk),
  .d (d),
  .q (q_f)
);

Latch l (
  .clk (clk),
  .d (d),
  .q (q_l)
);

always #(`CYC / 2) clk = ~clk;

initial begin
  @ (posedge clk)
  repeat (2 ** 4) begin
    @ (negedge clk) #1;
    d = $random;
  end
  #1 $finish;
end

endmodule
