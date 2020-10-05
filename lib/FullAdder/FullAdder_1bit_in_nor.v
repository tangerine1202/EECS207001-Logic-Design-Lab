`timescale 1ns/1ps

module FullAdder_1bit_in_nor (sum, cout, a, b, cin);

input a;
input b;
input cin;
output sum;
output cout;

wire x1;

Xnor_1bit_in_nor xnor_1bit_in_nor_0 (x1, a, b);
Xnor_1bit_in_nor xnor_1bit_in_nor_1 (sum, x1, cin);
Mux_1bit_in_nor  mux_1bit_in_nor_0 (
    .in0(cin),
    .in1(a),
    .sel(x1),
    .out(cout)
);

endmodule