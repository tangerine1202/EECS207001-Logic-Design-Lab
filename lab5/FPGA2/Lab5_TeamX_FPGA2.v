`timescale 1ns/1ps

module FPGA_2 (
    output [8-1:0] seg,
    output [4-1:0] an,
    output [4-1:0] affordable_drinks,
    input clk,
    input rst,      // top
    input insert_5,   // left
    input insert_10,  // center
    input insert_50,  // right
    input cancel,   // down
    inout wire PS2_DATA,
    inout wire PS2_CLK,
    // FIXME: only for debug
    input kb_rst
);

// Keyboard Press
parameter KB_A = 9'h1C;
parameter KB_S = 9'h1B;
parameter KB_D = 9'h23;
parameter KB_F = 9'h2B;
wire [511:0] key_down;
wire [8:0] last_change;
wire been_ready;

wire rst_op;
wire insert_5_op;
wire insert_10_op;
wire insert_50_op;
wire cancel_op;

reg press_A;
reg press_S;
reg press_D;
reg press_F;

// Clock Divider
wire second_div_sig;
wire display_div_sig;

wire [7:0] coins;

// Divide Clock
Clock_Divider #(.DIV_TIME(32'd100_000_000)) clk_div_second  (
   .div_sig(second_div_sig),
   .rst(rst_op),
   .clk(clk)
);
Clock_Divider #(.DIV_TIME(32'd100_000)) clk_div_general  (
   .div_sig(display_div_sig),
   .rst(rst_op),
   .clk(clk)
);


// Debounce and Onepulse signals
DeBounce_OnePulse #(.SIZE(8)) dbop_rst  (
    .sig_op(rst_op),
    .sig(rst),
    .clk(clk)//,
    // .div_sig(display_div_sig)
);
DeBounce_OnePulse #(.SIZE(8)) dbop_insert_5  (
    .sig_op(insert_5_op),
    .sig(insert_5),
    .clk(clk)//,
    // .div_sig(display_div_sig)
);
DeBounce_OnePulse #(.SIZE(8)) dbop_insert_10  (
    .sig_op(insert_10_op),
    .sig(insert_10),
    .clk(clk)//,
    // .div_sig(display_div_sig)
);
DeBounce_OnePulse #(.SIZE(8)) dbop_insert_50  (
    .sig_op(insert_50_op),
    .sig(insert_50),
    .clk(clk)//,
    // .div_sig(display_div_sig)
);
DeBounce_OnePulse #(.SIZE(8)) dbop_inst_cancel  (
    .sig_op(cancel_op),
    .sig(cancel),
    .clk(clk)//,
    // .div_sig(display_div_sig)
);


Vending_Machine vending_machine (
    .clk(clk),
    .second_div_sig(second_div_sig),
    // .display_div_sig(display_div_sig),
    .rst(rst_op),
    .insert_5_op(insert_5_op),
    .insert_10_op(insert_10_op),
    .insert_50_op(insert_50_op),
    .cancel_op(cancel_op),
    .press_A(press_A),
    .press_S(press_S),
    .press_D(press_D),
    .press_F(press_F),
    .affordable_drinks(affordable_drinks),
    .coins(coins)
);

Display_Money display_money (
    .an(an),
    .seg(seg),
    .coins(coins),
    .clk(clk),
    .div_sig(display_div_sig)
);


// keyboard decoder
KeyboardDecoder keyboard_de (
	.key_down(key_down),
	.last_change(last_change),
	.key_valid(been_ready),
	.PS2_DATA(PS2_DATA),
	.PS2_CLK(PS2_CLK),
	.rst(kb_rst),
	.clk(clk)
);

// Pre-process keyboard input
always @(posedge clk) begin
    if (been_ready && key_down[last_change] == 1'b1) begin
        press_A <= (last_change == KB_A) ? 1'b1 : 1'b0;
        press_S <= (last_change == KB_S) ? 1'b1 : 1'b0;
        press_D <= (last_change == KB_D) ? 1'b1 : 1'b0;
        press_F <= (last_change == KB_F) ? 1'b1 : 1'b0;
    end
    else begin
        press_A <= 1'b0;
        press_S <= 1'b0;
        press_D <= 1'b0;
        press_F <= 1'b0;
    end
end

endmodule


module Vending_Machine (
    input clk,
    input second_div_sig,
    // input display_div_sig,
    input rst,
    input insert_5_op,
    input insert_10_op,
    input insert_50_op,
    input cancel_op,
    input press_A,
    input press_S,
    input press_D,
    input press_F,
    output [3:0] affordable_drinks,
    output reg [7:0] coins
);

parameter INSERT_STATE = 1'b0;
parameter RETURN_STATE = 1'b1;

reg state;
reg next_state;
reg [7:0] next_coins;

assign affordable_drinks[3] = (coins < 8'd60) ? 1'b0 : 1'b1;
assign affordable_drinks[2] = (coins < 8'd30) ? 1'b0 : 1'b1;
assign affordable_drinks[1] = (coins < 8'd25) ? 1'b0 : 1'b1;
assign affordable_drinks[0] = (coins < 8'd20) ? 1'b0 : 1'b1;

always @(posedge clk) begin
    // if (display_div_sig == 1'b1) begin
        if (rst == 1'b1) begin
            state <= INSERT_STATE;
            coins <= 8'd0;
        end
        else begin
            if (state == RETURN_STATE) begin
                if (second_div_sig == 1'b1) begin
                    state <= next_state;
                    coins <= next_coins;
                end
                else begin
                    state <= state;
                    coins <= coins;
                end
            end
            else begin
                state <= next_state;
                coins <= next_coins;
            end
        end
    // end
    // else begin
    //     state <= state;
    //     coins <= coins;
    // end
end

// Update 'coins'
always @(*) begin
    case (state)
        INSERT_STATE: begin
            // Insert coins
            if (insert_5_op == 1'b1)
                if (coins < 8'd99 - 8'd5)
                    next_coins = coins + 8'd5;
                else
                    next_coins = 8'd99;
            else if (insert_10_op == 1'b1)
                if (coins < 8'd99 - 8'd10)
                    next_coins = coins + 8'd10;
                else
                    next_coins = 8'd99;
            else if (insert_50_op == 1'b1)
                if (coins < 8'd99 - 8'd50)
                    next_coins = coins + 8'd50;
                else
                    next_coins = 8'd99;
            // Buy items
            // $60
            else if (press_A == 1'b1 && affordable_drinks[3] == 1'b1)
                next_coins = coins - 8'd60;
            // $30
            else if (press_S == 1'b1 && affordable_drinks[2] == 1'b1)
                next_coins = coins - 8'd30;
            // $25
            else if (press_D == 1'b1 && affordable_drinks[1] == 1'b1)
                next_coins = coins - 8'd25;
            // $20
            else if (press_F == 1'b1 && affordable_drinks[0] == 1'b1)
                next_coins = coins - 8'd20;
            // cancel
            else if (cancel_op == 1'b1)
                next_coins = coins;
            else
                next_coins = coins;
        end
        RETURN_STATE: begin
            if (coins < 8'd5)
                next_coins = 8'd0;
            else
                next_coins = coins - 8'd5;
        end
        default: begin
            next_coins = coins;
        end
    endcase
end

// Update state
always @(*) begin
    case (state)
        INSERT_STATE: begin
            // $60
            if (press_A == 1'b1 && affordable_drinks[3] == 1'b1)
                next_state = RETURN_STATE;
            // $30
            else if (press_S == 1'b1 && affordable_drinks[2] == 1'b1)
                next_state = RETURN_STATE;
            // $25
            else if (press_D == 1'b1 && affordable_drinks[1] == 1'b1)
                next_state = RETURN_STATE;
            // $20
            else if (press_F == 1'b1 && affordable_drinks[0] == 1'b1)
                next_state = RETURN_STATE;
            // cancel
            else if (cancel_op == 1'b1 && coins > 8'd0)
                next_state = RETURN_STATE;
            else
                next_state = state;
        end
        RETURN_STATE: begin
            // FIXME: next_coins or coins == 0 ?
            if (next_coins == 8'd0)
                next_state = INSERT_STATE;
            else
                next_state = RETURN_STATE;
        end
        default: begin
            next_state = RETURN_STATE;
        end
    endcase
end


endmodule

module Display_Money (
    output [4-1:0] an,
    output reg [8-1:0] seg,
    input [8-1:0] coins,
    input clk,
    input div_sig
);

reg an_cnt;  // 1: 1101  0: 1110
reg [4-1:0] first_digit;

// an control
always @(posedge clk) begin
    if (div_sig == 1'b1)
        an_cnt <= an_cnt + 1'b1;
    else
        an_cnt <= an_cnt;
end

assign an[3:0] = (an_cnt == 1'b1) ? 4'b1101 : 4'b1110;

// seg control
always @(*) begin
    if (an_cnt == 1'b1) begin  // show 10's digit
        if (coins >= 8'd90)
            set_seg(4'd9);
        else if (coins >= 8'd80)
            set_seg(4'd8);
        else if (coins >= 8'd70)
            set_seg(4'd7);
        else if (coins >= 8'd60)
            set_seg(4'd6);
        else if (coins >= 8'd50)
            set_seg(4'd5);
        else if (coins >= 8'd40)
            set_seg(4'd4);
        else if (coins >= 8'd30)
            set_seg(4'd3);
        else if (coins >= 8'd20)
            set_seg(4'd2);
        else if (coins >= 8'd10)
            set_seg(4'd1);
        else
            set_seg(4'd0);
    end
    else begin  // show 1's digit
        first_digit = money[3:0];
        if (first_digit < 4'd10)
            set_seg(first_digit[3:0]);
        else begin
            set_seg(first_digit[3:0] - 4'd10);
        end
    end

end

task set_seg(input [3:0] digit);
begin
    case(digit)
        4'd0: seg = 8'b00000011;
        4'd1: seg = 8'b10011111;
        4'd2: seg = 8'b00100101;
        4'd3: seg = 8'b00001101;
        4'd4: seg = 8'b10011001;
        4'd5: seg = 8'b01001001;
        4'd6: seg = 8'b01000001;
        4'd7: seg = 8'b00011111;
        4'd8: seg = 8'b00000001;
        4'd9: seg = 8'b00001001;
        default: seg = 8'b01100000;  // error
    endcase
end
endtask

endmodule


module Clock_Divider(
    output reg div_sig,
    input rst,
    input clk
);

parameter DIV_TIME = 32'd100_000;
reg [32-1:0] cnt;

always @(posedge clk) begin
    if (rst == 1'b1) begin
        cnt <= 32'd0;
    end
    else begin
        if (cnt < DIV_TIME)
            cnt <= cnt + 32'd1;
        else
            cnt <= 32'd0;
    end
end

always @(*) begin
    if (cnt < DIV_TIME)
        div_sig = 1'b0;
    else
        div_sig = 1'b1;
end

endmodule

module DeBounce_OnePulse (
    output reg sig_op,
    input sig,
    input clk//,
    // input div_sig
);

parameter SIZE = 4;

// Debounce
reg [SIZE-1:0] dff;
wire sig_db;

always @(posedge clk) begin
    // if(div_sig == 1'b1) begin
        dff[SIZE-1:1] <= dff[SIZE-1-1:0];
        dff[0]        <= sig;
    // end
    // else
    //     dff[SIZE-1:0] <= dff[SIZE-1:0];
end

assign sig_db = &dff;

// Onepulse
reg sig_delay;
always @(posedge clk) begin
    // if (div_sig == 1'b1) begin
        // Calculate output signal
        if (sig_db == 1'b1 & sig_delay == 1'b0)
            sig_op <= 1'b1;
        else
            sig_op <= 1'b0;
        // Update signal delay
        sig_delay <= sig_db;
    // end
    // else begin
    //     // hold value
    //     sig_op <= sig_op;
    //     sig_delay <= sig_delay;
    // end
end

endmodule