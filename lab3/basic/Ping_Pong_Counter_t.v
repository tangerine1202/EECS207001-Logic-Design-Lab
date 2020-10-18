`timescale 1ns/1ps

`define CYC 4

module Ping_Pong_Counter_t;
reg clk = 1'b1;
reg rst_n = 1'b1;
reg enable = 1'b0;
wire direction;
wire [4-1:0] out;

Ping_Pong_Counter ppc (
  .clk (clk),
  .rst_n (rst_n),
  .enable (enable),
  .direction (direction),
  .out (out)
);

always #(`CYC / 2) clk = ~clk;

initial begin
  @ (negedge clk)
  rst_n = 1'b0;
  @ (negedge clk)
  rst_n = 1'b1;
  enable = 1'b1;

  #(`CYC * 20)
  enable = 1'b0;

  #(`CYC * 5)
  enable = 1'b1;

  #(`CYC * 20)
  $finish;
end
endmodule
