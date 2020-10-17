`timescale 100ps/1ps

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
  {a, b} = 8'b0;
  cin = 1'b0;
  repeat (2 ** 8) begin
    @ (posedge CLK)
      Test;
    @ (negedge CLK)
      {a, b} = {a, b} + 8'b1;
  end
  #1
  {a, b} = 8'b0;
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
  if (sum !== (a + b + cin) & 8'b00001111) begin
    $display("[ERROR] sum");
    $write("a: %d\n", a);
    $write("b: %d\n", b);
    $write("cin: %d\n", cin);
    $write("sum: %d\n", sum);
    $display;
  end
  if (cout !== (a + b + cin) & 8'b00010000) begin
    $display("[ERROR] cout");
    $write("a: %d\n", a);
    $write("b: %d\n", b);
    $write("cin: %d\n", cin);
    $write("cout: %d\n", cout);
    $display;
  end
end
endtask

endmodule
