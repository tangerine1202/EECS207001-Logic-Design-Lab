`timescale 1ns/1ps

`define CYC 4

module LFSR_t;

reg clk = 1'b1;
reg rst_n = 1'b1;
wire out;

LFSR lfsr (
  .clk(clk),
  .rst_n(rst_n),
  .out(out)
);

always #(`CYC/2) clk = ~clk;

initial begin
  @ (negedge clk)
  rst_n = 1'b0;
  @ (negedge clk)
  rst_n = 1'b1;

  #(`CYC * 50)
  $finish;
end

endmodule
