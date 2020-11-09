    `timescale 1ns/1ps

    module Greatest_Common_Divisor (clk, rst_n, Begin, a, b, Complete, gcd);
    input clk, rst_n;
    input Begin;
    input [16-1:0] a;
    input [16-1:0] b;
    output reg Complete;
    output reg [16-1:0] gcd;

    parameter WAIT = 2'b00;
    parameter CAL = 2'b01;
    parameter FINISH = 2'b10;

    reg [1:0] state;
    reg [1:0] next_state;
    reg cal_done;
    reg finish_done;
    reg [16-1:0] out;
    reg [16-1:0] next_a;
    reg [16-1:0] next_b;
    reg [16-1:0] cal_a;
    reg [16-1:0] cal_b;
    reg [1:0] finish_cnt;
    reg [1:0] next_finish_cnt;

    // Sequential: change current state 
    always @(posedge clk) begin
        if (rst_n == 1'b0) state <= WAIT;
        else               state <= next_state;
    end

    // Combinational: calculate next state
    always @(*) begin
        case(state)
            WAIT: begin
                if (Begin == 1'b1) next_state = CAL;
                else               next_state = WAIT;           
            end
            CAL: begin
                if (cal_done == 1'b1) next_state = FINISH;
                else                  next_state = CAL;
            end
            FINISH: begin
                if (finish_done == 1'b1) next_state = WAIT;
                else                     next_state = FINISH;
            end
        endcase
    end

    // [CAL] Sequentail: control calculate state
    always @(posedge clk) begin
        if (state == CAL) begin
            if (cal_a > cal_b) cal_a <= next_a;
            else               cal_b <= next_b;
        end
        else begin
            cal_a <= a;
            cal_b <= b;
        end
    end


    // [CAL] Combinational: calculate gcd
    always @(*) begin
        if (state == CAL) begin
            if (cal_a > cal_b) next_a = cal_a - cal_b;
            else               next_b = cal_b - cal_a;
        end
        else begin
            next_a = a;
            next_b = b;
        end
    end

    // [CAL] Combinational: raise cal_done flag
    always @(*) begin
        if (state == CAL) begin
            if (next_a == 16'h0) begin
                out = cal_b;
                cal_done = 1'b1;
            end
            else begin
                if (next_b == 16'h0) begin
                    out = cal_a;
                    cal_done = 1'b1;
                end
                else begin
                    out = out;
                    cal_done = cal_done;
                end
            end
        end
        else begin
            cal_done = 1'b0;
        end
    end 

    // [FINISH] Sequential: control finish state
    always @(posedge clk) begin
        if (state == FINISH) begin
            finish_cnt <= next_finish_cnt;
        end
        else begin
            finish_cnt <= 2'b00;
        end
    end

    // [FINISH] Combinational: count finish for 2 clk
    always @(*) begin
        if (state == FINISH) next_finish_cnt = finish_cnt + 2'b01;
        else                 next_finish_cnt = 2'b00;
    end

    // [FINISH] Combinational: raise finish_done flag
    always @(*) begin
        if (state == FINISH) begin
            if (next_finish_cnt == 2'b10) begin
                gcd = out;
                Complete = 1'b1;
                finish_done = 1'b1;
            end
            else begin
                gcd = out;
                Complete = 1'b1;
                finish_done = 1'b0;
            end
        end
        else begin
            gcd = 16'h0;
            Complete = 1'b0;
            finish_done = 1'b0;            
        end 
    end

    endmodule
