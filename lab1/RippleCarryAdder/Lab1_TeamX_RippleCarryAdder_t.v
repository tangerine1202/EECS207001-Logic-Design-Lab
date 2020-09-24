`timescale 1ns/1ps

module RippleCarryAdder_t;

parameter SIZE = 8;

reg [SIZE-1:0] a = 8'b0;
reg [SIZE-1:0] b = 8'b0;
reg [0:0] cin = 1'b0;
wire [SIZE-1:0] sum;
wire cout;

RippleCarryAdder fa (
  .a (a),
  .b (b),
  .cin (cin),
  .cout (cout),
  .sum (sum)
);

initial begin
  repeat (2 ** 4) begin
    #1 {a, b} = {a, b} + 16'b1;
    #1 cin = cin + 1'b1;
  end
  #1 {b, a} = 16'b0;
  repeat (2 ** 4) begin
    #1 {b, a} = {b, a} + 16'b1;
    #1 cin = cin + 1'b1;
  end

  #1 {a, b} = 16'hf800;
  repeat (2 ** 4) begin
    #1 {a, b} = {a, b} + 16'b1;
    #1 cin = cin + 1'b1;
  end
  #1 {b, a} = 16'hf800;
  repeat (2 ** 4) begin
    #1 {b, a} = {b, a} + 16'b1;
    #1 cin = cin + 1'b1;
  end

  #1 {a, b} = 16'hfff8;
  repeat (2 ** 3) begin
    #1 {a, b} = {a, b} + 16'b1;
    #1 cin = cin + 1'b1;
  end
  #1 {b, a} = 16'hfff8;
  repeat (2 ** 3) begin
    #1 {b, a} = {b, a} + 16'b1;
    #1 cin = cin + 1'b1;
  end

  #1 $finish;
end

endmodule
