`timescale 1ns/1ps

`define CYC 4

module Clock_divider_t;

reg clk = 1'b0;
reg rst_n = 1'b1;
wire clk_out;
wire clk_refresh;

Clock_divider clock_divider (
    .origin_clk(clk),
    .rst_n(rst_n),
    .clk_out(clk_out),
    .clk_refresh(clk_refresh)
);

always #(`CYC / 2) clk = !clk;

initial begin
    @ (negedge clk) 
    rst_n = 1'b0;
    @ (negedge clk) 
    rst_n = 1'b1;
    # (`CYC * 40_000_100);
end


endmodule