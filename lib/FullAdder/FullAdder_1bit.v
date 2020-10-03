`timescale 1ns/1ps

module FullAdder (sum, cout, a, b, cin);

input a;
input b;
input cin;
output sum;
output cout;

wire x1;

Xnor_1bit xnor_1bit_0 (
  .a(a),
  .b(b),
  .out(x1)
);

Xnor_1bit xnor_1bit_1 (
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

