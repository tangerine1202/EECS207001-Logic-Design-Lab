`timescale 1ns/1ps

module Binary_to_Grey (din, dout);

input [4-1:0] din;
output [4-1:0] dout;

wire [4-1:0] din_n;

nand nand0 (din_n[0], din[0], din[0]);
nand nand1 (din_n[1], din[1], din[1]);
nand nand2 (din_n[2], din[2], din[2]);
nand nand3 (din_n[3], din[3], din[3]);

// output[3] equal to input[3]
nand nand4 (dout[3], din_n[3], din_n[3]);

// output[2] control by input [3]
Mux_1bit_in_nand mux0 (
  .in0(din[2]),
  .in1(din_n[2]),
  .sel(din[3]),
  .out(dout[2])
);

// output[1] control by input[2]
Mux_1bit_in_nand mux1 (
  .in0(din[1]),
  .in1(din_n[1]),
  .sel(din[2]),
  .out(dout[1])
);

// output[0] control by input[1]
Mux_1bit_in_nand mux2 (
  .in0(din[0]),
  .in1(din_n[0]),
  .sel(din[1]),
  .out(dout[0])
);

endmodule


module Mux_1bit_in_nand (out, in1, in0, sel);

input in0;
input in1;
input sel;
output out;

wire sel_n;
wire nand_in_0;
wire nand_in_1;

nand (sel_n, sel, sel);
nand nand0 (nand_in_1, in1, sel);
nand nand1 (nand_in_0, in0, sel_n);
nand nand2 (out, nand_in_1, nand_in_0);

endmodule
