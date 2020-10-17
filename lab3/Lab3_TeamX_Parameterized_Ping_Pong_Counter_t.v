`timescale 1ns/1ps

module Parameterized_Ping_Pong_Counter ();
reg clk = 0;
reg rst_n = 1;
reg enable = 1;
reg flip = 0;
reg [4-1:0] max = 15, min = 15;
wire direction;
wire [4-1:0] out;

Parameterized_Ping_Pong_Counter_t pppc (
    .clk(clk), 
    .rst_n(rst_n), 
    .enable(enable), 
    .flip(flip), 
    .max(max), 
    .min(min), 
    .direction(direction), 
    .out(out)
);

initial begin
    #1 rst_n = 0;
    repeat(2**4 - 1) begin
        #1 
    end
end

endmodule