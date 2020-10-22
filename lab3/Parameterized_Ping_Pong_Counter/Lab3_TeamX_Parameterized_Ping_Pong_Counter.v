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
    if (rst_n == 1'b0) begin
        direction <= 1'b1;
    end
    else begin
        direction <= next_direction;
    end
end

// Sequential: out
always @(posedge clk) begin
    if (rst_n == 1'b0) begin
        out <= min;
    end
    else begin
        out <= next_out;
    end
end

// Combinational: next_direction
always @(*) begin
    if (enable) begin
        if (max > min) begin
            if (out >= min && out <= max) begin
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
        else begin
            next_direction = direction;
        end
    end
    else begin
        next_direction = direction;
    end
end

// Combinational: next_out
always @(*) begin
    if (enable) begin
        if (max > min) begin
            if (out >= min && out <= max) begin
                if (next_direction == 1'b1) begin
                    next_out = out + 4'b0001;
                end
                else if (next_direction == 1'b0) begin
                    next_out = out - 4'b0001;
                end
                else begin
                    next_out = out;
                end
            end
            else begin
                next_out = out;
            end
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
