`timescale 1ns/1ps

module Sliding_Window_Detector (clk, rst_n, in, dec1, dec2);

input clk, rst_n;
input in;
output dec1, dec2;

Detect1 Dec1 (
    .dec1(dec1),
    .in(in),
    .clk(clk),
    .rst_n(rst_n)
);

Detect2 Dec2 (
    .dec2(dec2),
    .in(in),
    .clk(clk),
    .rst_n(rst_n)
);

endmodule

module Detect1 (dec1, in, clk, rst_n);

parameter WAIT = 3'd0;
parameter FIRST_ONE = 3'd1;
parameter SECOND_ZERO = 3'd2;
parameter SECOND_ONE = 3'd3;
parameter THIRD_ONE = 3'd4;
parameter STOP = 3'd5;

input in;
input clk;
input rst_n;
output reg dec1;

reg [3-1:0] state;
reg [3-1:0] next_state;

always @(posedge clk) begin
    if (rst_n == 1'b0) begin
        state <= WAIT;
    end
    else begin
        state <= next_state;
    end
end

always @(*) begin
    case(state)
        WAIT: begin
            if (in == 1'b1) begin
                next_state = FIRST_ONE;
                dec1 = 1'b0;
            end
            else begin
                next_state = WAIT;
                dec1 = 1'b0;
            end
        end
        FIRST_ONE: begin
            if (in == 1'b1) begin
                next_state = SECOND_ONE;
                dec1 = 1'b0;
            end
            else begin
                next_state = SECOND_ZERO;
                dec1 = 1'b0;
            end
        end
        SECOND_ZERO: begin
            if (in == 1'b1) begin
                next_state = FIRST_ONE;
                dec1 = 1'b1;
            end
            else begin
                next_state = WAIT;
                dec1 = 1'b0;
            end
        end
        SECOND_ONE: begin
            if (in == 1'b1) begin
                next_state = THIRD_ONE;
                dec1 = 1'b0;
            end
            else begin
                next_state = SECOND_ZERO;
                dec1 = 1'b0;
            end 
        end
        THIRD_ONE: begin
            if (in == 1'b1) begin
                next_state = STOP;
                dec1 = 1'b0;
            end
            else begin
                next_state = SECOND_ZERO;
                dec1 = 1'b0;
            end
        end
        STOP: begin
            next_state = STOP;
            dec1 = 1'b0;
        end
        default: begin
            next_state = next_state;
            dec1 = 1'b0;
        end
    endcase 
end

endmodule

module Detect2 (dec2, in, clk, rst_n);

parameter WAIT = 2'd0;
parameter FIRST_ONE = 2'd1;
parameter SECOND_ONE = 2'd2;
parameter THIRD_ZERO = 2'd3;

input in;
input clk;
input rst_n;
output reg dec2;

reg [2-1:0] state;
reg [2-1:0] next_state;

always @(posedge clk) begin
    if (rst_n == 1'b0) begin
        state <= WAIT;
    end
    else begin
        state <= next_state;
    end
end

always @(*) begin
    case(state)
        WAIT: begin
            if (in == 1'b1) begin
                next_state = FIRST_ONE;
                dec2 = 1'b0;
            end
            else begin
                next_state = WAIT;
                dec2 = 1'b0;
            end
        end
        FIRST_ONE: begin
            if (in == 1'b1) begin
                next_state = SECOND_ONE;
                dec2 = 1'b0;
            end
            else begin
                next_state = WAIT;
                dec2 = 1'b0;
            end
        end
        SECOND_ONE: begin
            if (in == 1'b1) begin
                next_state = SECOND_ONE;
                dec2 = 1'b0;
            end
            else begin
                next_state = THIRD_ZERO;
                dec2 = 1'b0;
            end
        end
        THIRD_ZERO: begin
            if (in == 1) begin
                next_state = FIRST_ONE;
                dec2 = 1'b1;
            end
            else begin
                next_state = WAIT;
                dec2 = 1'b0;
            end
        end
        default: begin
            next_state = next_state;
            dec2 = 1'b0;
        end
    endcase
end

endmodule