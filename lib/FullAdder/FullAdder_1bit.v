`timescale 1ns/1ps

module FullAdder (sum, cout, a, b, cin);

input a;
input b;
input cin;
output sum;
output cout;

wire x1;

Nxor_1bit nxor_1bit_0 (
  .a(a),
  .b(b),
  .out(x1)
);

Nxor_1bit nxor_1bit_1 (
  .a(x1),
  .b(cin),
  .out(sum)
);

Mux_1bit mux_1bit_0 (
  .in1(cin),
  .in0(a),
  .sel(x1),
  .out(cout)
);

endmodule

