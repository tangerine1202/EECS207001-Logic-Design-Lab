`timescale 1ns/1ps

module Mux_8bits_t;

reg [8-1:0] a = 8'h00;
reg [8-1:0] b = 8'h0f;
reg [8-1:0] c = 8'hf0;
reg [8-1:0] d = 8'hff;
reg sel1 = 1'b0;
reg sel2 = 1'b0;
reg sel3 = 1'b0;
wire [8-1:0] f;

Mux_8bits mux_8bits (
  .a(a),
  .b(b),
  .c(c),
  .d(d),
  .sel1(sel1),
  .sel2(sel2),
  .sel3(sel3),
  .f(f)
);

initial begin
  repeat (2 ** 3) begin
    #1 {sel3, sel2, sel1} = {sel3, sel2, sel1} + 3'b1;
  end
  #1 $finish;
end

endmodule