`timescale 1ns/1ps

module Comparator_4bits_t;

reg [4-1:0] a = 4'b0;
reg [4-1:0] b = 4'b0;
wire lt, eq, gt;

Comparator_4bits cmp_4bits_0(
  .a(a),
  .b(b),
  .a_lt_b(lt),
  .a_eq_b(eq),
  .a_gt_b(gt)
);
    
initial begin
  repeat (2 ** 8) begin
    #1 {a, b} = {a, b} + 8'b1;
  end
  #1 $finish;
end

endmodule
