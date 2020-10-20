`timescale 1ns/1ps

module Ping_Pong_Counter (clk, rst_n, enable, direction, out);

input clk;
input rst_n;
input enable;
output reg direction;
output reg [4-1:0] out;

reg next_direction;
reg [4-1:0] next_out;


// Sequential Circuit
always @(posedge clk) begin
    if (rst_n == 1'b0) begin
        out <= 4'b0001;
    end
    else begin
        out <= next_out;
    end
end

// Sequential Circuit
always @(posedge clk) begin
    if (rst_n == 1'b0) begin
        direction <= 1'b1;
    end
    else begin
        direction <= next_direction;
    end
end

// Combinational Circuit
// determine next direction by last 'out'
always @(*) begin
    if (out == 4'b0000) begin
        next_direction = 1'b1;
    end
    else if (out == 4'b1111) begin
        next_direction = 1'b0;
    end
    else begin
        next_direction = direction;
    end
end

// Combinational Circuit
// determine next out by next direction
always @(*) begin
    if (enable == 1'b1) begin
        if (next_direction == 1'b1) begin
            next_out = out + 4'b1;
        end
        else begin
            next_out = out - 4'b1;
        end
    end
    else begin
        next_out = next_out;
    end
end

endmodule
