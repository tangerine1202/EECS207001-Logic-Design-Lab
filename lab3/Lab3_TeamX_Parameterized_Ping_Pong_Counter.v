`timescale 1ns/1ps 

module Parameterized_Ping_Pong_Counter (clk, rst_n, enable, flip, max, min, direction, out);
input clk, rst_n;
input enable;
input flip;
input [4-1:0] max;
input [4-1:0] min;
output direction;
output [4-1:0] out;

reg drct;
reg [4-1:0] cnt;
reg f;

always @(posedge clk or negedge rst_n) begin
    if (rst_n == 0) begin
        drct <= 1'b1;
        cnt <= min;
    end
    else begin
        if (flip == 1) begin
            f <= 1'b1;
        end
        if (enable && max > min) begin
            if (drct == 1 && cnt <= max) begin
                cnt <= cnt + 1'b1; 
            end
            else if (drct == 0 && cnt >= min) begin
                cnt <= cnt - 1'b1;
            end
        end
    end
end

assign direction = drct;
assign out = cnt;

endmodule
