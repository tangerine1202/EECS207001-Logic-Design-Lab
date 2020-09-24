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

<<<<<<< HEAD
Mux_1bit m1 (
  .in1(a),
  .in0(cin),
=======
Mux_1bit mux_1bit_0 (
  .in1(cin),
  .in0(a),
>>>>>>> 584f5812fe30a67f3853ad0ec044f118be6ec747
  .sel(x1),
  .out(cout)
);

endmodule

