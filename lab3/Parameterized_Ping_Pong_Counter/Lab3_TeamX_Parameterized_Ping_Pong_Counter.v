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
    if (enable) begin 
        if (flip == 1'b1) begin
            next_direction = !direction;
        end
        else begin 
            if (out == min) begin
                next_direction = 1'b1;
            end
            else if (out == max) begin
                next_direction = 1'b0;
            end
            else begin 
                next_direction = direction;
            end
        end
    end
    else begin
        next_direction = direction;
    end
end

// Combinational: next_out
always @(*) begin
    if (enable && (max > min)) begin
        if (next_direction == 1'b1 && out < max) begin
            next_out = out + 1'b1;
        end
        else if (next_direction == 1'b0 && out > min) begin
            next_out = out - 1'b1;
        end
        else begin 
            next_out = out;
        end
    end 
    else begin
        next_out = out;
    end
end

endmodule
