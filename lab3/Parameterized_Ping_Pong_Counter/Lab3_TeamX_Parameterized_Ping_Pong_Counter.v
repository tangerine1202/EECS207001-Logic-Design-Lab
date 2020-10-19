`timescale 1ns/1ps 

module Parameterized_Ping_Pong_Counter (clk, rst_n, enable, flip, max, min, direction, out);
input clk, rst_n;
input enable;
input flip;
input [4-1:0] max;
input [4-1:0] min;
output reg direction;
output reg [4-1:0] out;

reg next_direction;
reg [4-1:0] next_out;

// Sequential: direction
always @(posedge clk) begin
    if (rst_n == 1'b0)
        direction <= 1'b1;
    else
        direction <= next_direction;
end

// Sequential: out
always @(posedge clk) begin
    if (rst_n == 1'b0)
        out <= min;
    else 
        out <= next_out;
end

// Combinational: next_direction
always @(*) begin
    if (flip == 1'b1)
        next_direction = !direction;
    else if (out == min)
        next_direction = 1'b1;
    else if (out == max)
        next_direction = 1'b0;
    else 
        next_direction = direction;
end

// Combinational: next_out
always @(*) begin
    if (enable && max > min) begin
        if (next_direction == 1'b1 && out < max) 
            next_out = out + 1'b1;
        else if (next_direction == 1'b0 && out > min)
            next_out = out - 1'b1;
        else 
            next_out = out;
    end 
    else 
        next_out = out;
end

endmodule
