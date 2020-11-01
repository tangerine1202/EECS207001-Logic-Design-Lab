`timescale 1ns/1ps

module Greatest_Common_Divisor (clk, rst_n, Begin, a, b, Complete, gcd);
input clk, rst_n;
input Begin;
input [16-1:0] a;
input [16-1:0] b;
output Complete;
output [16-1:0] gcd;

parameter WAIT = 2'b00;
parameter CAL = 2'b01;
parameter FINISH = 2'b10;

endmodule
