`timescale 1ns/1ps

module Decode_and_Execute (op_code, rs, rt, rd);

parameter SIZE = 4;

input [3-1:0] op_code;
input [SIZE-1:0] rs, rt;
output [SIZE-1:0] rd;

wire [SIZE-1:0] out_add;
wire [SIZE-1:0] out_sub;
wire [SIZE-1:0] out_inc;
wire [SIZE-1:0] out_bitwise_nor;
wire [SIZE-1:0] out_bitwise_nand;
wire [SIZE-1:0] out_rsdiv4;
wire [SIZE-1:0] out_rsmul2;
wire [SIZE-1:0] out_mul;

wire [8-1:0] out_dec;
wire [SIZE-1:0] and_out_add;
wire [SIZE-1:0] and_out_sub;
wire [SIZE-1:0] and_out_inc;
wire [SIZE-1:0] and_out_bitwise_nor;
wire [SIZE-1:0] and_out_bitwise_nand;
wire [SIZE-1:0] and_out_rsdiv4;
wire [SIZE-1:0] and_out_rsmul2;
wire [SIZE-1:0] and_out_mul;

ADD add_0 (
  .in0(rs),
  .in1(rt),
  .out(out_add)
);

SUB sub_0 (
  .in0(rs),
  .in1(rt),
  .out(out_sub)
);

INC inc_0 (
  .in(rs),
  .out(out_inc)
);

Bitwise_Nor bitwise_nor_0 (
  .in0(rs),
  .in1(rt),
  .out(out_bitwise_nor)
);

Bitwise_Nand bitwise_nand_0 (
  .in0(rs),
  .in1(rt),
  .out(out_bitwise_nand)
);

RsDiv4 rsdiv4_0 (
  .in(rs),
  .out(out_rsdiv4)
);

RsMul2 rsmul2_0 (
  .in(rs),
  .out(out_rsmul2)
);

MUL mul_0 (
  .in0(rs),
  .in1(rt),
  .out(out_mul)
);


// TODO: Quad 3bits Mux here
//assign rd = op_code === 3'b110 ? out_rsmul2 : out_mul;
Decoder_3x8_in_nor dec_3x8_in_nor (
  .out(out_dec),
  .sel(op_code)
);


And_4bits_fanout and_4bits_fanout_0 (.out(and_out_add), .in(out_add), .fan(out_dec[0]));
And_4bits_fanout and_4bits_fanout_1 (.out(and_out_sub), .in(out_sub), .fan(out_dec[1]));
And_4bits_fanout and_4bits_fanout_2 (.out(and_out_inc), .in(out_inc), .fan(out_dec[2]));
And_4bits_fanout and_4bits_fanout_3 (.out(and_out_bitwise_nor), .in(out_bitwise_nor), .fan(out_dec[3]));
And_4bits_fanout and_4bits_fanout_4 (.out(and_out_bitwise_nand), .in(out_bitwise_nand), .fan(out_dec[4]));
And_4bits_fanout and_4bits_fanout_5 (.out(and_out_rsdiv4), .in(out_rsdiv4), .fan(out_dec[5]));
And_4bits_fanout and_4bits_fanout_6 (.out(and_out_rsmul2), .in(out_rsmul2), .fan(out_dec[6]));
And_4bits_fanout and_4bits_fanout_7 (.out(and_out_mul), .in(out_mul), .fan(out_dec[7]));

Or_4x8_4bits_in_nor or_4x8_4bits_in_nor_0 (rd, {and_out_add, and_out_sub, and_out_inc, and_out_bitwise_nor, and_out_bitwise_nand, and_out_rsdiv4, and_out_rsmul2, and_out_mul});

    
//    always @(rs or rt) begin
//        $display("[Check]\n");
//        $write("sel: %3b\n", op_code);
//        $write("inc: %4b\n", out_inc);
//        $write("out: %4b\n", and_out_inc);
//        $write("rd: %4b\n", rd);
//        $write("add: %4b\n", and_out_add);
//        $write("sub: %4b\n", and_out_sub);
//        $write("nor: %4b\n", and_out_bitwise_nor);
//        $write("nand: %4b\n", and_out_bitwise_nand);
//        $write("rsdiv4: %4b\n", and_out_rsdiv4);
//        $write("rsmul2: %4b\n", and_out_rsmul2);
//        $write("mul: %4b\n", and_out_mul);
//        $display;
//    end
    

endmodule

module And_4bits_fanout(out, in, fan);
input [4-1:0] in;
input fan;
output [4-1:0] out;

wire fan_n;
wire [4-1:0] fanout;

Not_1bit_in_nor not_1bit_in_nor_0 (fan_n, fan);
Not_1bit_in_nor not_1bit_in_nor_1 (fanout[0], fan_n);
Not_1bit_in_nor not_1bit_in_nor_2 (fanout[1], fan_n);
Not_1bit_in_nor not_1bit_in_nor_3 (fanout[2], fan_n);
Not_1bit_in_nor not_1bit_in_nor_4 (fanout[3], fan_n);
And_1bit_in_nor and_1bit_in_nor_0 [4-1:0] (out, in, fanout);

endmodule

module ADD (out, in0, in1);

parameter SIZE = 4;

input [SIZE-1:0] in0;
input [SIZE-1:0] in1;
output [SIZE-1:0] out;

wire dummy_cout;
wire const_zero;
wire in0_0_n;

nor in0_0_n_0 (in0_0_n, in0[0], in0[0]);
nor const_zero_0 (const_zero, in0[0], in0_0_n);

FullAdder_4bits_in_nor fa_4bits_in_nor (
  .sum(out),
  .cout(dummy_cout),
  .a(in0),
  .b(in1),
  .cin(const_zero)
);

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
  .out(out)
);

endmodule


module Two_complement (out, in);

parameter SIZE = 4;

input [SIZE-1:0] in;
output [SIZE-1:0] out;

wire [SIZE-1:0] in_n;

nor in_n_0 [SIZE-1:0] (in_n, in, in);

INC out_0 (
  .in(in_n),
  .out(out)
);

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

nor in_n_0 [SIZE-1:0] (in_n, in, in);

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
nor in_n_0 [SIZE-1-1:0] (in_n, in[SIZE-1-1:0], in[SIZE-1-1:0]);

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

Multiplier_4x4_4bits_in_nor mul_4x4_4bits_in_nor (
  .out(out),
  .a(in0),
  .b(in1)
);

endmodule