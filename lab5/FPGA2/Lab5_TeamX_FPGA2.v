`timescale 1ns/1ps

module FPGA_2 (
    output reg gen_div_sig,
    output reg inst50_cond,
    output [8-1:0] seg,
    output [4-1:0]  an,
    output [4-1:0]  LED_drinks_affordable,
    input clk,
    input rst,      // top
    input inst_5,   // left
    input inst_10,  // center
    input inst_50,  // right
    input cancel,   // down
    inout wire PS2_DATA,
    inout wire PS2_CLK
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
wire inst_5_op;
wire inst_10_op;
wire inst_50_op;
wire cancel_op;
reg press_A;
reg press_S;
reg press_D;
reg press_F;

// Clock Divider
wire second_div_sig;
wire general_div_sig;

// State Control
parameter INSERT_COIN = 2'b00;
parameter BUY_DRINK = 2'b01;
parameter RETURN_MONEY = 2'b10;
reg [1:0] state;
reg [1:0] next_state;
reg goto_buy;
reg goto_return;

// Money Control
parameter MONEY_BIT = 8;
reg [MONEY_BIT-1:0] current_money;
reg [MONEY_BIT-1:0] next_money;
reg [MONEY_BIT-1:0] next_money_cost;
reg [MONEY_BIT-1:0] next_money_return;
reg [MONEY_BIT-1:0] collect_coin;
reg [MONEY_BIT-1:0] buy_cost;

/* ---- debug ---- */
always @(posedge clk) begin
    // if (current_money == 8'd0 || gen_div_sig == 1'b1)
    //     gen_div_sig <= 1'b1;
    // else
    //     gen_div_sig <= 1'b0;
    gen_div_sig = goto_return;
end
always @(*) begin
    inst50_cond = state;
end

// Divide Clock
Clock_Divider #(.DIV_TIME(32'd100_000_000)) clk_div_second  (
   .div_sig(second_div_sig),
   .rst(rst_op),
   .clk(clk)
);
Clock_Divider #(.DIV_TIME(32'd100_000)) clk_div_general  (
   .div_sig(general_div_sig),
   .rst(rst_op),
   .clk(clk)
);

// Debounce and Onepulse signals
DeBounce_OnePulse #(.SIZE(4)) dbop_rst  (
    .sig_op(rst_op),
    .sig(rst),
    .clk(clk),
    .div_sig(general_div_sig)
);
DeBounce_OnePulse #(.SIZE(4)) dbop_inst_5  (
    .sig_op(inst_5_op),
    .sig(inst_5),
    .clk(clk),
    .div_sig(general_div_sig)
);
DeBounce_OnePulse #(.SIZE(4)) dbop_inst_10  (
    .sig_op(inst_10_op),
    .sig(inst_10),
    .clk(clk),
    .div_sig(general_div_sig)
);
DeBounce_OnePulse #(.SIZE(4)) dbop_inst_50  (
    .sig_op(inst_50_op),
    .sig(inst_50),
    .clk(clk),
    .div_sig(general_div_sig)
);
DeBounce_OnePulse #(.SIZE(4)) dbop_inst_cancel  (
    .sig_op(cancel_op),
    .sig(cancel),
    .clk(clk),
    .div_sig(general_div_sig)
);

Display_Money display_money (
    .an(an),
    .seg(seg),
    .money(current_money),
    .clk(clk),
    .div_sig(general_div_sig)
);

Display_Affordable_Drinks dsad (
    .LED(LED_drinks_affordable),
    .money(current_money)
);

KeyboardDecoder keyboard_de (
	.key_down(key_down),
	.last_change(last_change),
	.key_valid(been_ready),
	.PS2_DATA(PS2_DATA),
	.PS2_CLK(PS2_CLK),
	.rst(rst_op),
	.clk(clk)
);


// State Control
always @(posedge clk) begin
   if(rst_op == 1'b1) begin
       state <= INSERT_COIN;
    end
    else begin
        if(general_div_sig == 1'b1)
            state <= next_state;
        else 
            state <= state;
    end
end
always @(*) begin
    case(state)
        INSERT_COIN:  begin
            if (goto_buy == 1'b1)
                next_state = BUY_DRINK;
            else if (goto_return == 1'b1)
                next_state = RETURN_MONEY;
            else    
                next_state = INSERT_COIN; 
        end
        BUY_DRINK: begin
            if (goto_return == 1'b1)
                next_state = RETURN_MONEY;
            else
                next_state = BUY_DRINK;
        end
        RETURN_MONEY: begin
            if (goto_return == 1'b0)
                next_state = INSERT_COIN; 
            else
                next_state = RETURN_MONEY;
        end
        default: begin
            next_state = next_state;
        end
    endcase
end

// Money Control
always @(posedge clk) begin
    if (rst_op == 1'b1) begin
        current_money <= 8'd0;
    end
    else  begin
        if (state == INSERT_COIN) begin
            if (general_div_sig == 1'b1)
                current_money <= next_money;
            else
                current_money <= current_money;
        end
        else if (state == BUY_DRINK) begin
            if (general_div_sig == 1'b1)
                current_money <= next_money_cost;
            else
                current_money <= current_money;
        end
        else if (state == RETURN_MONEY) begin
            if(second_div_sig == 1'b1)
                current_money <= next_money_return;
            else
                current_money <= current_money;        
        end
        else begin
            current_money <= current_money;
        end
    end
end

// Money Control: Insert Coin
always @(*) begin
    collect_coin = 8'd0;

    if (inst_5_op == 1'b1) begin
        collect_coin = 8'd5;
    end
    else begin
        if (inst_10_op == 1'b1) begin
            collect_coin = 8'd10;
        end
        else begin
            if (inst_50_op == 1'b1) begin
                collect_coin = 8'd50; 
            end
            else begin
                collect_coin = collect_coin;
            end
        end
    end

    next_money = current_money + collect_coin;

    if(next_money > 8'd99)
        next_money = 8'd99;
    else
        next_money = next_money;
end

// Buy drink
always @(*) begin
    buy_cost = 8'd0;
    goto_buy = 1'b0;

    if (state == INSERT_COIN) begin
        if (press_A) begin
            buy_cost = 8'd60;
            goto_buy = 1'b1;
        end
        else begin
            if (press_S) begin
                buy_cost = 8'd30; 
                goto_buy = 1'b1;
            end
            else begin
                if (press_D) begin
                    buy_cost = 8'd25; 
                    goto_buy = 1'b1;
                end
                else begin
                    if (press_F) begin
                        buy_cost = 8'd20; 
                        goto_buy = 1'b1;
                    end
                    else begin
                        buy_cost = buy_cost;
                        goto_buy = goto_buy;
                    end
                end
            end
        end
        next_money_cost = current_money - buy_cost;
    end
    else begin
        next_money_cost = current_money;
    end
end

// Money Control: return money
always @(*) begin
    if (state == INSERT_COIN) begin
        if (cancel_op == 1'b1)
            goto_return = 1'b1;
        else 
            goto_return = 1'b0;
    end
    else if (state == BUY_DRINK) begin
        if (current_money == 8'd0)
            goto_return = 1'b1;
        else
            goto_return = 1'b0;
    end
    else if (state == RETURN_MONEY) begin
        if(current_money == 8'd0)
            goto_return = 1'b0;
        else begin
            goto_return = 1'b1;
            next_money_return = current_money - 8'd5;
        end
    end
    else begin
        goto_return = 1'b0;
        next_money_return = current_money;
    end
end


// Press Button
always @(posedge clk) begin
    if (been_ready && key_down[last_change]) begin
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

module Display_Money (
    output reg [4-1:0] an,
    output reg [8-1:0] seg,
    input [8-1:0] money,
    input clk,
    input div_sig
);

reg an_cnt;  // 1: 1101  0: 1110
reg [8-1:0] first_digit;

// an control
always @(posedge clk) begin
    if (div_sig == 1'b1)
        an_cnt <= an_cnt + 1'b1;
    else
        an_cnt <= an_cnt;
end
always @(*) begin
    if (an_cnt == 1'b1)
        an = 4'b1101;
    else
        an = 4'b1110;
end

// seg control
always @(*) begin
    if (an_cnt == 1'b1) begin  // show 10's digit
        if (money >= 8'd90)
            set_seg(4'd9);
        else if (money >= 8'd80)
            set_seg(4'd8);
        else if (money >= 8'd70)
            set_seg(4'd7);
        else if (money >= 8'd60)
            set_seg(4'd6);
        else if (money >= 8'd50)
            set_seg(4'd5);
        else if (money >= 8'd40)
            set_seg(4'd4);
        else if (money >= 8'd30)
            set_seg(4'd3);
        else if (money >= 8'd20)
            set_seg(4'd2);
        else if (money >= 8'd10)
            set_seg(4'd1);
        else
            set_seg(4'd0);
    end
    else begin  // show 1's digit
        first_digit = money;
        if (first_digit > 8'd9) begin
            first_digit = first_digit - 8'd10;
            if(first_digit > 8'd9) begin
                first_digit = first_digit - 8'd10;
                if(first_digit > 8'd9) begin
                    first_digit = first_digit - 8'd10;
                    if(first_digit > 8'd9) begin
                        first_digit = first_digit - 8'd10;
                        if(first_digit > 8'd9) begin
                            first_digit = first_digit - 8'd10;
                            if(first_digit > 8'd9) begin
                                first_digit = first_digit - 8'd10;
                                if(first_digit > 8'd9) begin
                                    first_digit = first_digit - 8'd10;
                                    if(first_digit > 8'd9) begin
                                        first_digit = first_digit - 8'd10;
                                        if(first_digit > 8'd9) begin
                                            first_digit = first_digit - 8'd10;
                                            set_seg(first_digit[3:0]);
                                        end
                                        else begin
                                            set_seg(first_digit[3:0]);
                                        end
                                    end
                                    else begin
                                        set_seg(first_digit[3:0]);
                                    end
                                end
                                else begin
                                    set_seg(first_digit[3:0]);
                                end
                            end
                            else begin
                                set_seg(first_digit[3:0]);
                            end
                        end
                        else begin
                            set_seg(first_digit[3:0]);
                        end
                    end
                    else begin
                        set_seg(first_digit[3:0]);
                    end
                end
                else begin
                    set_seg(first_digit[3:0]);
                end
            end
            else begin
                set_seg(first_digit[3:0]);
            end
        end
        else begin
            set_seg(first_digit[3:0]);
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

module Display_Affordable_Drinks (
    output reg [4-1:0] LED,
    input [8-1:0] money
);

always @(*) begin
    if (money >= 8'd60)
        LED[3:0] = 4'b1111;
    else if (money >= 8'd30)
        LED[3:0] = 4'b0111;
    else if (money >= 8'd25)
        LED[3:0] = 4'b0011;
    else if (money >= 8'd20)
        LED[3:0] = 4'b0001;
    else
        LED[3:0] = 4'b0000;
end

endmodule

module Clock_Divider(
    output reg div_sig,
    input rst,
    input clk
);

parameter DIV_TIME = 32'd100_000;
reg [32-1:0] cnt;

always @(posedge clk) begin
    // if (rst == 1'b1) begin
    //     cnt <= 32'd0;
    // end
    // else begin
    //     if (cnt < DIV_TIME)
    //         cnt <= cnt + 32'd1;
    //     else 
    //         cnt <= 32'd0;
    //         // cnt <= cnt;
    // end
    if (cnt < DIV_TIME)
        cnt <= cnt + 32'd1;
    else 
        cnt <= 32'd0;
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
    input clk,
    input div_sig
);

parameter SIZE = 4;

// Debounce
reg [SIZE-1:0] dff;
reg sig_db;
// Onepulse
reg sig_delay;

always @(posedge clk) begin
    if(div_sig == 1'b1) begin
        dff[SIZE-1:1] <= dff[SIZE-1-1:0];
        dff[0]   <= sig;
    end
    else
        dff[SIZE-1:0] <= dff[SIZE-1:0];
end
always @(*) begin
    sig_db = &dff;
end

always @(posedge clk) begin
    if (div_sig == 1'b1) begin 
        if (sig_db == 1'b1 & sig_delay == 1'b0)
            sig_op <= 1'b1;
        else
            sig_op <= 1'b0;
        sig_delay <= sig_db;
    end
    else begin
        sig_delay <= sig_delay;
    end
end

endmodule