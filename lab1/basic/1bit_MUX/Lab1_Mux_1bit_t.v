`timescale 1ns/1ps

module Mux_1bit_t;
reg a = 1'b0;
reg b = 1'b0;
reg sel = 1'b0;
wire f;

Mux_1bit m1 (
  .a (a),
  .b (b),
  .sel (sel),
  .f (f)
);

initial begin
  repeat (2 ** 3) begin
    #1 {sel, a, b} = {sel, a, b} + 1'b1;
  end
  #1 $finish;
end
endmodule
