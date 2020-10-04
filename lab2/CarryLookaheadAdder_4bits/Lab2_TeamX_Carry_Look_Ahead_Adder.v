`timescale 1ns/1ps

module Carry_Look_Ahead_Adder (a, b, cin, cout, sum);

parameter SIZE = 4;

input [SIZE-1:0] a, b;
input cin;
output cout;
output [SIZE-1:0] sum;

wire [SIZE-1:0] p;
wire [SIZE-1:0] g;
wire c1;
wire c2;
wire c3;
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

FullAdder_1bit_in_nand fa0  (
  .a(a[1]),
  .b(b[1]),
  .cin(c[1]),
  .p(p[1]),
  .g(g[1]),
  .sum(sum[1])
);

FullAdder_1bit_in_nand fa0  (
  .a(a[2]),
  .b(b[2]),
  .cin(c[2]),
  .p(p[2]),
  .g(g[2]),
  .sum(sum[2])
);

FullAdder_1bit_in_nand fa0  (
  .a(a[3]),
  .b(b[3]),
  .cin(c[3]),
  .p(p[3]),
  .g(g[3]),
  .sum(sum[3])
);

Carry_Look_Ahead_4bits cla_4bit (
  .p(p),
  .g(g),
  .cin(cin),
  // .pg(pg),   // not used in lab2
  // .gg(gg),   // not used in lab2
  .cout(cout)
);

endmodule


module Carry_Look_Ahead_4bits (pg, gg, cout, p, g, cin);

parameter SIZE = 4;

input [SIZE-1:0] p;       // Propagate output from FullAdder
input [SIZE-1:0] g;       // Generate output from FullAdder
input cin;                // initial carry-in c0
output pg;                // Group Propagate
output gg;                // Group Generate
output [SIZE-1:0] cout;   // Carry-out

wire [SIZE-1:0] g_n;    // !g
wire [SIZE-1:0] pc_n;   // !(p AND c[x])
wire pg_n;              // !pg
wire [SIZE-1-1:0] gp_n; // !(g AND p)


nand nand_g_n [SIZE-1:0] (g_n, g, g);

// cout
// c1 = g0 + (p0 * c0) = !(!g0 * !(p0 * c0))
nand nand_pc_n0 (pc_n[0], p[0], cin);
nand nand_c1 (cout[1], g_n[0], pc_n[0]);

// c2 = g1 + (p1 * c1) = !(!g1 * !(p1 * c1))
nand nand_pc_n1 (pc_n[1], p[1], cout[1]);
nand nand_c1 (cout[2], g_n[1], pc_n[1]);

// c3 = g2 + (p2 * c2) = !(!g2 * !(p2 * c2))
nand nand_pc_n2 (pc_n[2], p[2], cout[2]);
nand nand_c1 (cout[3], g_n[2], pc_n[2]);

// c4 = g3 + (p3 * c3) = !(!g3 * !(p3 * c3))
nand nand_pc_n3 (pc_n[3], p[3], cout[3]);
nand nand_c1 (cout[4], g_n[3], pc_n[3]);


// pg = p0 * p1 * p2 * p3 = !(!(p0 * p1 * p2 * p3))
nand nand_pg_n (pg_n, p[0], p[1], p[2], p[3]);
nand nand_pg (pg, pg_n, pg_n);

// gg = g3 + (g2 * p3) + (g1 * p3 * p2) + (g0 * p3 * p2 * p1) = !(!g3 * !(g2 * p3) * !(g1 * p3 * p2) * !(g0 * p3 * p2 * p1))
nand nand_gp_n_2 (gp_n[2], g[2], p[3]);
nand nand_gp_n_1 (gp_n[1], g[1], p[3], p[2]);
nand nand_gp_n_0 (gp_n[0], g[0], p[3], p[2], p[1]);
nand nand_gg (gg, g_n[3], gp_n[2], gp_n[1], gp_n[0]);


endmodule


module FullAdder_1bit_in_nand (sum, g, p, a, b, cin);

input a;
input b;
input cin;
output cout;
output sum;

wire a_n;
wire b_n;
wire cin_n;
wire ab_n;
wire abc;
wire abncn;
wire anbcn;
wire anbnc;


nand nand0 (a_n, a, a);
nand nand1 (b_n, b, b);
nand nand2 (cin_n, cin, cin);

// generate output
nand nand3 (ab_n, a, b);
nand nand4 (g, ab_n, ab_n);

// propagate output
nand nand5 (p, a_n, b_n);

// sum output
nand nand6 (abc, a, b, c);
nand nand7 (abncn, a, b_n, c_n);
nand nand8 (anbcn, a_n, b, c_n);
nand nand9 (anbnc, a_n, b_n, c);
nand nand10 (sum, abc, abncn, anbcn, anbnc);


endmodule

