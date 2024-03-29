`timescale 1ns/1ps

module Carry_Look_Ahead_Adder (a, b, cin, cout, sum);

parameter SIZE = 4;

input [SIZE-1:0] a;
input [SIZE-1:0] b;
input cin;
output cout;
output [SIZE-1:0] sum;

wire [SIZE-1:0] p;
wire [SIZE-1:0] g;
wire [SIZE-1-1:0] c;  // c1, c2, c3
// wire pg;  // not used in lab2
// wire gg;  // not used in lab2


FullAdder_1bit_in_nand fa0  (
  .a(a[0]),
  .b(b[0]),
  .cin(cin),
  .p(p[0]),
  .g(g[0]),
  .sum(sum[0])
);

FullAdder_1bit_in_nand fa1  (
  .a(a[1]),
  .b(b[1]),
  .cin(c[1-1]),
  .p(p[1]),
  .g(g[1]),
  .sum(sum[1])
);

FullAdder_1bit_in_nand fa2  (
  .a(a[2]),
  .b(b[2]),
  .cin(c[2-1]),
  .p(p[2]),
  .g(g[2]),
  .sum(sum[2])
);

FullAdder_1bit_in_nand fa3  (
  .a(a[3]),
  .b(b[3]),
  .cin(c[3-1]),
  .p(p[3]),
  .g(g[3]),
  .sum(sum[3])
);

Carry_Look_Ahead_4bits cla_4bit (
  .p(p),
  .g(g),
  .cin(cin),
//  .pg(pg),   // not used in lab2
//  .gg(gg),   // not used in lab2
  .cout({cout, c[3-1:1-1]})
);

endmodule


module Carry_Look_Ahead_4bits (cout, p, g, cin);

parameter SIZE = 4;

input [SIZE-1:0] p;       // Propagate output from FullAdder
input [SIZE-1:0] g;       // Generate output from FullAdder
input cin;                // initial carry-in c0
output [SIZE-1:0] cout;   // Carry-out
// output pg;                // Group Propagate
// output gg;                // Group Generate

wire [10-1:0] ws;       // lots of wires to calculate for c[1~4]
wire [SIZE-1:0] g_n;    // !g
// wire pg_n;              // !pg
// wire [SIZE-1-1:0] gp_n; // !(g AND p)


nand nand_g_n [SIZE-1:0] (g_n, g, g);

// cout
// c1 = g0 + (p0 * c0)
//    = !(!g0 * !(p0 * c0))
nand nand_pc_n0 (ws[0], p[0], cin);
nand nand_c1 (cout[1-1], g_n[0], ws[0]);

// c2 = g1 + (p1 * c1) = g1 + (g0 * p1) + (c0 * p0 * p1)
//    = !(!g1 * !(g0 * p1) * !(c0 * p0 * p1))
nand nand_c2_0 (ws[1], g[0], p[1]);
nand nand_c2_1 (ws[2], cin, p[1], p[0]);
nand nand_c2 (cout[2-1], g_n[1], ws[1], ws[2]);

// c3 = g2 + (p2 * c2) = g2 + (g1 * p2) + (g0 * p1 * p2) + (c0 * p0 * p1 * p2)
//    = !(!g2 * !(g1 * p2) * !(g0 * p1 * p2) * !(c0 * p0 * p1 * p2))
nand nand_c3_0 (ws[3], g[1], p[2]);
nand nand_c3_1 (ws[4], g[0], p[2], p[1]);
nand nand_c3_2 (ws[5], cin, p[2], p[1], p[0]);
nand nand_c3 (cout[3-1], g_n[2], ws[3], ws[4], ws[5]);

// c4 = g3 + (p3 * c3) = g3 + (g2 * p3) + (g1 * p3 * p2) + (g0 * p3 * p2 * p1) + (cin * p3 * p2 * p1 * p0)
//    = !(!g3 * !(g2 * p3) * !(g1 * p3 * p2) * !(g0 * p3 * p2 * p1) * !(cin * p3 * p2 * p1 * p0))
nand nand_c4_0(ws[6], g[2], p[3]);
nand nand_c4_1(ws[7], g[1], p[3], p[2]);
nand nand_c4_2(ws[8], g[0], p[3], p[2], p[1]);
nand nand_c4_3(ws[9], cin, p[3], p[2], p[1], p[0]);
nand nand_c4 (cout[4-1], g_n[3], ws[6], ws[7], ws[8], ws[9]);


// pg = p0 * p1 * p2 * p3
//    = !(!(p0 * p1 * p2 * p3))
// nand nand_pg_n (pg_n, p[0], p[1], p[2], p[3]);
// nand nand_pg (pg, pg_n, pg_n);

// gg = g3 + (g2 * p3) + (g1 * p3 * p2) + (g0 * p3 * p2 * p1)
//    = !(!g3 * !(g2 * p3) * !(g1 *p3 * p2) * !(g0 * p3 *p2 * p1))
// nand nand_gp_n_2 (gp_n[2], g[2], p[3]);
// nand nand_gp_n_1 (gp_n[1], g[1], p[3], p[2]);
// nand nand_gp_n_0 (gp_n[0], g[0], p[3], p[2], p[1]);
// nand nand_gg (gg, g_n[3], gp_n[2], gp_n[1], gp_n[0]);


endmodule


module FullAdder_1bit_in_nand (sum, p, g, a, b, cin);

input a;
input b;
input cin;
output p;
output g;
output sum;

wire a_n;   // !a
wire b_n;   // !b
wire cin_n; // !cin
wire ab;    // !(a * b)
wire abc;   // !(a * b * cin)
wire abncn; // !(a * b_n * cin_n)
wire anbcn; // !(a_n * b * cin_n)
wire anbnc; // !(a_n * b_n * cin)


nand nand0 (a_n, a, a);
nand nand1 (b_n, b, b);
nand nand2 (cin_n, cin, cin);

// generate output
nand nand3 (ab, a, b);
nand nand4 (g, ab, ab);

// propagate output
nand nand5 (p, a_n, b_n);

// sum output
nand nand6 (abc, a, b, cin);
nand nand7 (abncn, a, b_n, cin_n);
nand nand8 (anbcn, a_n, b, cin_n);
nand nand9 (anbnc, a_n, b_n, cin);
nand nand10 (sum, abc, abncn, anbcn, anbnc);


endmodule