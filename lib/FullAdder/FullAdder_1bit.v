`timescale 1ns/1ps

module FullAdder (sum, cout, a, b, cin);
input a, b;
input cin;
output sum;
output cout;

wire x1;

NXOR nxor1 (
  .a(a),
  .b(b),
  .out(x1)
);

NXOR nxor2 (
  .a(x1),
  .b(cin),
  .out(sum)
);

Mux_1bit m1 (
  .in1(a),
  .in0(cin),
  .sel(x1),
  .out(cout)
);

endmodule

module NXOR (a, b, out);
input a, b;
output out;

wire x1, x2;

nor nor0 (x1, a, b);
and and0 (x2, a, b);
or  or0  (out, x1, x2);

endmodule
