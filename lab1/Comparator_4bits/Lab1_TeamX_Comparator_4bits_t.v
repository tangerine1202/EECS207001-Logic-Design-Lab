`timescale 1ns/1ps

module Comparator_4bits_t;

parameter SIZE = 4;

reg [SIZE-1:0] a = 4'b0;
reg [SIZE-1:0] b = 4'b0;
//reg a = 1'b0;
//reg b = 1'b0;
wire lt, gt, eq;

Comparator_4bits cmp(
    .a(a),
    .b(b),
    .a_lt_b(lt),
    .a_gt_b(gt),
    .a_eq_b(eq)
    );
    
initial begin
  repeat (2 ** 8) begin
    #1 {a, b} = {a, b} + 1'b1;
  end
  #1 $finish;
end

endmodule
