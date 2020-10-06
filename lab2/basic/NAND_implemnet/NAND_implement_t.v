`timescale 1ns/1ps

module NAND_Implement_t;

reg a = 1'b0;
reg b = 1'b0;
reg [3-1:0] sel = 3'd0;
wire out;

NAND_Implement nand_i (
  .a (a),
  .b (b),
  .sel (sel),
  .out (out)
);

initial begin
  repeat (2 ** 5) begin
    #1 {sel, a, b} = {sel, a, b} + 1'b1;
  end
  #1 $finish;
end
endmodule
