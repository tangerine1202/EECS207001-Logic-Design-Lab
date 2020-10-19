`timescale 1ns/1ps

module Clock_Divider (clk, rst_n, sel, clk1_2, clk1_4, clk1_8, clk1_3, dclk);

input clk;
input rst_n;
input [2-1:0] sel;
output clk1_2;
output clk1_4;
output clk1_8;
output clk1_3;
output reg dclk;

reg [4-1:0] cnt_2;      // count from 0 to 1
reg [4-1:0] cnt_4;      // count from 0 to 3
reg [4-1:0] cnt_8;      // count from 0 to 7
reg [4-1:0] cnt_3;      // count from 0 to 2


// Sequential Circuit
always @(posedge clk) begin
    if (rst_n == 1'b0) begin
        cnt_2 <= 4'b0;
        cnt_4 <= 4'b0;
        cnt_8 <= 4'b0;
        cnt_3 <= 4'b0;
    end
    else begin
        // cnt_2
        if (cnt_2 == 4'd1)
            cnt_2 <= 4'b0;
        else
            cnt_2 <= cnt_2 + 4'b1;
        // cnt_4
        if (cnt_4 == 4'd3)
            cnt_4 <= 4'd0;
        else
            cnt_4 <= cnt_4 + 4'b1;
        // cnt_8
        if (cnt_8 == 4'd7)
            cnt_8 <= 4'b0;
        else
            cnt_8 <= cnt_8 + 4'b1;
        // cnt_3
        if (cnt_3 == 4'd2)
            cnt_3 <= 4'b0;
        else
            cnt_3 <= cnt_3 + 4'b1;
    end
end

// Combinational Circuit
assign clk1_2 = (cnt_2 == 4'd1 ? 1'b1 : 1'b0);
assign clk1_4 = (cnt_4 == 4'd3 ? 1'b1 : 1'b0);
assign clk1_8 = (cnt_8 == 4'd7 ? 1'b1 : 1'b0);
assign clk1_3 = (cnt_3 == 4'd2 ? 1'b1 : 1'b0);

// Combinational Circuit
always @(*) begin
    case (sel)
        2'b00: dclk = clk1_3;
        2'b01: dclk = clk1_2;
        2'b10: dclk = clk1_4;
        2'b11: dclk = clk1_8;
        default: dclk = 4'b0;
    endcase
end


endmodule
