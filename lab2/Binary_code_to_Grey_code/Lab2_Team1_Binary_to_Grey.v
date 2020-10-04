`timescale 1ns/1ps

module Binary_to_Grey (din, dout);

parameter SIZE = 4;

input [SIZE-1:0] din;
output [SIZE-1:0] dout;

wire [SIZE-1:0] din_n;

nand nand0 (din_n[0], din[0]);
nand nand1 (din_n[1], din[1]);
nand nand2 (din_n[2], din[2]);
nand nand3 (din_n[3], din[3]);

// 1st bit output equal 1st bit input
nand nand4 (dout[0], din_n[0]);

// 2nd bit output control by 1st bit input
Mux_1bit_in_nand mux0 (
  .in0(din[1]),
  .in1(din_n[1]),
  .sel(d_out[0]),
  .out(dout[1])
);

// 3rd bit output control by 2nd bit input
Mux_1bit_in_nand mux1 (
  .in0(din[2]),
  .in1(din_n[2]),
  .sel(d_out[1]),
  .out(dout[2])
);

// 2nd bit output control by 1 bit input
Mux_1bit_in_nand mux2 (
  .in0(din[3]),
  .in1(din_n[3]),
  .sel(d_out[2]),
  .out(dout[3])
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

nand (sel_n, sel);
nand nand0 (nand_in_1, in1, sel);
nand nand1 (nand_in_0, in0, sel_n);
nand nand2 (out, nand_in_1, nand_in_0);

endmodule
