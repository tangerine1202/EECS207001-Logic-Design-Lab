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
  repeat (2 ** 8) begin
    #1 a = a + 1'b1;
    #1 b = b + 1'b1;
    #1 cin = cin + 1'b1;
  end
  #1 $finish;
end

endmodule
