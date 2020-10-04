`timescale 1ns/1ps

module A_and_not_b_1bit_t;
reg a = 1'b0;
reg b = 1'b0;
wire out;

A_and_not_b_1bit aanb (
    .out(out),
    .a(a),
    .b(b)
);

initial begin
  repeat (2 ** 2) begin
    #1 {a, b} = {a, b} + 1'b1;
  end
  #1 $finish;
end

endmodule