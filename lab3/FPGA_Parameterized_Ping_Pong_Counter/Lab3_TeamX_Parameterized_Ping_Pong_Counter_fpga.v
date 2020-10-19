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

reg flip_debounced;
reg flip_one_pluse;
reg rst_n_debounced;
reg rst_n_one_pluse;

// Sequential: flip debouncing
Debounce debounce_flip (
    .pb_debounced(flip_debounced),
    .pb(flip),
    .clk(clk)
);
One_pulse one_pluse_flip (
    .pb_one_pluse(flip_one_pluse),
    .pb_debounced(flip_debounced),
    .clk(clk)
);

// Sequential: rst_n debouncing
Debounce debounce_rst_n (
    .pb_debounced(rst_n_debounced),
    .pb(rst_n),
    .clk(clk)
);
One_pulse one_pluse_rst_n (
    .pb_one_pluse(rst_n_one_pluse),
    .pb_debounced(rst_n_debounced),
    .clk(clk)
);

// Sequential: direction
always @(posedge clk) begin
    if (rst_n_one_pluse == 1'b0)
        direction <= 1'b1;
    else
        direction <= next_direction;
end

// Sequential: out
always @(posedge clk) begin
    if (rst_n_one_pluse == 1'b0)
        out <= min;
    else 
        out <= next_out;
end

// Combinational: next_direction
always @(*) begin
    if (flip_one_pluse == 1'b1)
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

module Debounce(pb_debounced, pb, clk);

input pb;
input clk;
output pb_debounced;

reg [4-1:0] dff;

always @(posedge clk) begin
    dff[3:1] <= dff[2:0];
    dff[0] <= pb;
end

assign pb_debounced = (dff == 4'b1111) ? 1'b1 : 1'b0;

endmodule

module One_pulse(pb_one_pluse, pb_debounced, clk);

input pb_debounced;
input clk;
output reg pb_one_pluse;

reg pb_debounced_delay;

always @(posedge clk) begin
    pb_one_pluse <= pb_debounced & (!pb_debounced_delay);
    pb_debounced_delay <= pb_debounced;
end

endmodule