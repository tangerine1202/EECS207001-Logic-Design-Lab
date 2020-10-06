`timescale 1ns/1ps

module Carry_Look_Ahead_Adder_t;

parameter SIZE = 4;

reg [SIZE-1:0] a = 4'b0;
reg [SIZE-1:0] b = 4'b0;
reg cin = 1'b0;
wire cout;
wire [SIZE-1:0] sum;

integer t_a = 0;
integer t_b = 0;
integer t_cin = 0;
reg [3:0] t_sum = 0;
reg t_cout = 0;

Carry_Look_Ahead_Adder cla (
  .a (a),
  .b (b),
  .cin (cin),
  .cout (cout),
  .sum (sum)
);


initial begin
  repeat (2 ** 8) begin
    #1
    {a, b} = {a, b} + 8'b1;
    assertion(a, b, cin, cout, sum);
    #1
    cin = cin + 1'b1;
    assertion(a, b, cin, cout, sum);
  end
  #1 $finish;
end

task assertion;
  input [SIZE-1:0] a;
  input [SIZE-1:0] b;
  input cin;
  input cout;
  input [SIZE-1:0] sum;
  begin
    t_a = a;
    t_b = b;
    t_cin = cin;
    t_sum = (t_a + t_b + t_cin);
    t_cout = (t_a + t_b + t_cin) >> 4;
  end
endtask

endmodule
