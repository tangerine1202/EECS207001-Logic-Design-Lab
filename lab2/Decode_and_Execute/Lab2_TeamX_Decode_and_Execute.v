`timescale 1ns/1ps

module Decode_and_Execute (op_code, rs, rt, rd);

input [3-1:0] op_code;
input [4-1:0] rs, rt;
output [4-1:0] rd;

case (op_code)
  3'b000:
    ADD add_0 (
      .in0(rs),
      .in1(rt),
      .out(rd)
    );
  3'b001:
    SUB sub_0 (
      .in0(rs),
      .in1(rt),
      .out(rd)
    );
  3'b010:
    INC inc_0 (
      .in(rs),
      .out(rd)
    );
  3'b011:
    Bitwise_Nor bitwise_nor_0 (
      .in0(rs),
      .in1(rt),
      .out(rd)
    );
  3'b100:
    Bitwise_Nand bitwise_nand_0 (
      .in0(rs),
      .in1(rt),
      .out(rd)
    );
  3'b101:
    RsDiv4 rsdiv4_0 (
      .in(rs),
      .out(rd)
    );
  3'b110:
    RsMul2 rsmul2_0 (
      .in(rs),
      .out(rd)
    );
  3'b111:
    MUL mul_0 (
      .in0(rs),
      .in1(rt),
      .out(rd)
    );
  default:
    assign rd = 4'bXXXX;
endcase

endmodule


module ADD (out, in0, in1);

parameter SIZE = 4;

input [SIZE-1:0] in0;
input [SIZE-1:0] in1;
output [SIZE-1:0] out;

// reg added;
// added = in0+in1;
// assign out = added;

assign out = in0 + in1;

endmodule


module SUB (out, in0, in1);

parameter SIZE = 4;

input [SIZE-1:0] in0;
input [SIZE-1:0] in1;
output [SIZE-1:0] out;

wire [SIZE-1:0] in1_2sComplemnt;


Two_complement in1_2sComplemnt_0 (
  .in(in1),
  .out(in1_2sComplemnt)
);

ADD add_2sComplement (
  .in0(in0),
  .in1(in1_2sComplemnt),
  .out(out),
);

endmodule


module Two_complement (out, in);

parameter SIZE = 4;

input [SIZE-1:0] in;
output [SIZE-1:0] out;

wire [SIZE-1:0] inc_one;


INC inc_0 (
  .in(in),
  .out(inc_one)
);
nor out_0 [SIZE-1:0] (out, inc_one, inc_one);

endmodule


module INC (out, in);

parameter SIZE = 4;

input [SIZE-1:0] in;
output [SIZE-1:0] out;

wire [SIZE-1:0] inc_one;
wire in0_n;               // in[0]_n
wire const_zero;
// wire const_one;


nor in0_n_0 (in0_n, in[0], in[0]);
nor const_zero_0 (const_zero, in[0], in0_n);

// To improve performance, direct generate const one on output
nor inc_one_0 (inc_one[0], const_zero, const_zero);
// To improve performance, direct generate const zero on output
nor inc_one_1 [3-1:0] (inc_one[3:1], in[0], in0_n);

ADD add_0 (
  .in0(in),
  .in1(inc_one),
  .out(out)
);

endmodule

module Bitwise_Nor (out, in0, in1);

parameter SIZE = 4;

input [SIZE-1:0] in0;
input [SIZE-1:0] in1;
output [SIZE-1:0] out;


nor bitwise_nor [SIZE-1:0] (out, in0, in1);

endmodule


module Bitwise_Nand (out, in0, in1);

parameter SIZE = 4;

input [SIZE-1:0] in0;
input [SIZE-1:0] in1;
output [SIZE-1:0] out;

Nand_1bit_in_nor bitwise_nand [SIZE-1:0] (
  .in0(in0),
  .in1(in1),
  .out(out)
);

endmodule


module Nand_1bit_in_nor (out, in0, in1);

input in0;
input in1;
output out;

wire in0_n;
wire in1_n;
wire out_n;


nor in0_n_0 (in0_n, in0, in0);
nor in1_n_0 (in1_n, in1, in1);

nor out_n_0 (out_n, in0_n, in1_n);
nor out_0 (out, out_n, out_n);

endmodule


module RsDiv4 (out, in);

parameter SIZE = 4;

input [SIZE-1:0] in;
output [SIZE-1:0] out;

wire [SIZE-1:0] in_n;
// wire const_zero;

nor in_n [SIZE-1:0] (in_n, in, in);

// To improve performance, direct generate const zero on out[2], out[3]
// nor const_zero_0 (const_zero, in[0], in_n0]);

nor out_0 (out[0], in_n[2], in_n[2]);   // in_n[2]
nor out_1 (out[1], in_n[3], in_n[3]);   // in_n[3]
nor out_2 (out[2], in[0], in_n[0]);     // zero
nor out_3 (out[3], in[0], in_n[0]);     // zero

endmodule


module RsMul2 (out, in);

parameter SIZE = 4;

input [SIZE-1:0] in;
output [SIZE-1:0] out;

// in[3] didn't used, so -1
wire [SIZE-1-1:0] in_n;

// wire const_zero;


// in[3] didn't used, so -1
nor in_n [SIZE-1-1:0] (in_n, in, in);

// To improve performance, direct generate const zero on out[2], out[3]
// nor const_zero_0 (const_zero, in[0], in_n[0]);

nor out_0 (out[0], in[0], in_n[0]);     // zero
nor out_1 (out[1], in_n[0], in_n[0]);   // in_n[0]
nor out_2 (out[2], in_n[1], in_n[1]);   // in_n[1]
nor out_3 (out[3], in_n[2], in_n[2]);   // in_n[2]

endmodule


module MUL (out, in0, in1);

parameter SIZE = 4;

input [SIZE-1:0] in0;
input [SIZE-1:0] in1;
output [SIZE-1:0] out;

// reg muled;
// muled = in0*in1;
// assign out = muled;

assign out = in0 * in1;

endmodule