`timescale 1ns/1ps

module FullAdder_t;
reg a = 1'b0;
reg b = 1'b0;
reg cin = 1'b0;
wire [2-1:0] out;

FullAdder fa (
  .a (a),
  .b (b),
  .cin (cin),
  .cout (out [1]),
  .sum (out [0])
);

initial begin
  repeat (2 ** 3) begin
    #1 {a, b, cin} = {a, b, cin} + 1'b1;
  end
  #1 $finish;
end

endmodule
