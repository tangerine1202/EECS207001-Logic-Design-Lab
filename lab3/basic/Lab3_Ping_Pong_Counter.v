`timescale 1ns/1ps

module Ping_Pong_Counter (clk, rst_n, enable, direction, out);
input clk, rst_n;
input enable;
output reg direction;
output reg [4-1:0] out;

reg [4-1:0] next_out;
reg next_dr;

always @(posedge clk) begin
    if (rst_n == 1'b0) begin
        out <= 4'b0001;
    end
    else if (enable == 1'b1) begin
        out <= next_out;
    end
    else begin
        out <= out;
    end
end

always @(posedge clk) begin
    if (rst_n == 1'b0) begin
        direction <= 1'b1;
    end
    else begin
        direction <= next_dr;
    end
end


// CC: calculate 'next_out' which depend on 'direction'
always @(*) begin
    next_out = out;
    if (next_dr == 1'b1) begin
        next_out = out + 4'b1;
    end
    else begin
        next_out = out - 4'b1;
    end
end

// CC: calculate 'direction' which depend on 'out'
always @(*) begin
    next_dr = direction;
    if (out == 4'b0000) begin
        next_dr = 1'b1;
    end
    else if (out == 4'b1111) begin
        next_dr = 1'b0;
    end
    else begin
        next_dr = next_dr;
    end
end


endmodule
