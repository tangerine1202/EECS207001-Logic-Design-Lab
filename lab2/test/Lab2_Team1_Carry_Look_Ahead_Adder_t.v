`timescale 1ns/1ps

module Carry_Look_Ahead_Adder_t;

parameter SIZE = 4;

reg CLK = 0;

reg [SIZE-1:0] a = 4'b0;
reg [SIZE-1:0] b = 4'b0;
reg cin = 1'b0;
wire cout;
wire [SIZE-1:0] sum;


Carry_Look_Ahead_Adder cla_adder (
  .a (a),
  .b (b),
  .cin (cin),
  .cout (cout),
  .sum (sum)
);

always #1 CLK = ~CLK;

initial begin
  cin = 1'b0;
  repeat (2 ** 8) begin
    @ (posedge CLK)
      Test;
    @ (negedge CLK)
      {a, b} = {a, b} + 8'b1;
  end
  cin = 1'b1;
  repeat (2 ** 8) begin
    @ (posedge CLK)
      Test;
    @ (negedge CLK)
      {a, b} = {a, b} + 8'b1;
  end
  #1 $finish;
end

task Test;
begin
  if (cout !== (a + b) & 8'b00001111) begin
    $display("[ERROR] cout");
    $write("a: %d\n", a);
    $write("b: %d\n", b);
    $write("cout: %d\n", cout);
    $display;
  end
  if (sum !== (a + b) >> 4) begin
    $display("[ERROR] sum");
    $write("a: %d\n", a);
    $write("b: %d\n", b);
    $write("sum: %d\n", sum);
    $display;
  end
end
endtask

endmodule
