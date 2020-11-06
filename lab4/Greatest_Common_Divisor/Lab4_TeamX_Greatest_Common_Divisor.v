`timescale 1ns/1ps

module Greatest_Common_Divisor (clk, rst_n, Begin, a, b, Complete, gcd);
input clk, rst_n;
input Begin;
input reg [16-1:0] a;
input reg [16-1:0] b;
output reg Complete;
output reg [16-1:0] gcd;

parameter WAIT = 2'b00;
parameter CAL = 2'b01;
parameter FINISH = 2'b10;

reg state;
reg next_state;
reg cal_done;
reg finish_done;
reg out;
reg next_a;
reg next_b;
reg [1:0] complete_cnt;
reg next_gcd;
reg next_complete;

// Sequential: change current state 
always @(posedge clk) begin
    if (rst_n == 1'b0) state <= WAIT;
    else               state <= next_state;
end

// Combinational: calculate next state
always @(*) begin
    case(state)
        WAIT: begin
            if (Begin == 1'b1) next_state <= CAL;
            else               next_state <= WAIT;           
        end
        CAL: begin
            if (cal_done == 1'b1) next_state <= FINISH;
            else                  next_state <= CAL;
        end
        FINISH: begin
            if (finish_done == 1'b1) next_state <= WAIT;
            else                      next_state <= FINISH;
        end
    endcase
end

// [CAL] Sequentail: control calculate state
always @(posedge clk) begin
    if (state == CAL) begin
        a <= next_a;
        b <= next_b;
    end
    else begin
        a <= a;
        b <= b;
    end
end

// [CAL] Combinational: calculate gcd
always @(*) begin
    if (state == CAL) begin
        if (a == 16'h0) begin
            out <= b;
            cal_done <= 1'b1;
        end
        else begin
            if (b == 16'h0) begin
                out <= a;
                cal_done <= 1'b1;
            end
            else begin
                if (a > b) next_a <= a - b;
                else       next_b <= b - a;
            end
        end
    end
    else begin
        out <= 16'h0;
        cal_done <= 1'b0;
    end
end

// [FINISH] Sequential: control finish state
always @(posedge clk) begin
    if (state == FINISH) begin
        gcd <= next_gcd;
        Complete <= next_complete;
    end
    else begin
        gcd <= gcd;
        Complete <= Complete;
    end
end

// [FINISH] Combinational: count complete clock
always @(*) begin
    if (state == FINISH) begin
        if (complete_cnt == 2'b10) begin
            finish_done = 1'b1;
        end
        else begin
            next_gcd = out;
            next_complete = 1'b1;
            complete_cnt = complete_cnt + 2'b01;
        end 
    end
    else begin
        next_gcd = 16'h0;
        next_complete = 1'b0;
        complete_cnt = 2'b00;
    end
end

endmodule
