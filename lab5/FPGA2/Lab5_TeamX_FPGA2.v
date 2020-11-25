`timescale 1ns/1ps

module FPGA_2 (
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

// Money Control
parameter MONEY_BIT = 9;
reg [MONEY_BIT-1:0] current_money;
reg [MONEY_BIT-1:0] next_money;
reg [MONEY_BIT-1:0] collect_coin;

// add debounce and one pulse to signals
DeBounce_OnePulse #(.SIZE(4)) dbop_rst  (
    .sig_op(rst_op),
    .sig(rst),
    .clk(clk)
);
DeBounce_OnePulse #(.SIZE(4)) dbop_inst_5  (
    .sig_op(inst_5_op),
    .sig(inst_5),
    .clk(clk)
);
DeBounce_OnePulse #(.SIZE(4)) dbop_inst_10  (
    .sig_op(inst_10_op),
    .sig(inst_10),
    .clk(clk)
);
DeBounce_OnePulse #(.SIZE(4)) dbop_inst_50  (
    .sig_op(inst_50_op),
    .sig(inst_50),
    .clk(clk)
);
DeBounce_OnePulse #(.SIZE(4)) dbop_inst_cancel  (
    .sig_op(cancel_op),
    .sig(cancel),
    .clk(clk)
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
	.rst(rst),
	.clk(clk)
);

// Money Control
always @(posedge clk) begin
    if (rst == 1'b1) begin
        current_money <= 9'd0;
    end
    else  begin
        current_money <= next_money;
    end
end

always @(*) begin
    collect_coin = 9'd0;

    if (inst_50_op == 1'b1) begin
        collect_coin = collect_coin + 9'd5;
    end
    else begin
        if (inst_10_op == 1'b1) begin
            collect_coin = collect_coin + 9'd10;
        end
        else begin
            if (inst_50_op == 1'b1) begin
                collect_coin = collect_coin + 9'd50; 
            end
            else begin
                collect_coin = collect_coin;
            end
        end
    end
    
    next_money = current_money + collect_coin;

    if(next_money > 9'd99)
        next_money = 9'd99;
    else
        next_money = next_money;
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

// module Display_Money (
//     output reg [4-1:0] an,
//     output reg [8-1:0] sig,
//     input [9-1:0] money,
//     input clk,
// );

// reg an_cnt;  // 1: 1101  0: 1110

// // an control
// always @(posedge clk) begin
//     an_cnt <= an_cnt + 1'b01;
// end
// always @(*) begin
//     an = (an_cnt == 1'b1) ? 4'b1101 : 4'b1110;
// end

// // sig control
// always @(*) begin
//     if (ant_cnt == 1'b1) begin
//         if (money >= 8'd90)
//             set_sig(4'd9);
//         else if (money >= 8'd80)
//             set_sig(4'd8);
//         else if (money >= 8'd70)
//             set_sig(4'd7);
//         else if (money >= 8'd60)
//             set_sig(4'd6);
//         else if (money >= 8'd50)
//             set_sig(4'd5);
//         else if (money >= 8'd40)
//             set_sig(4'd4);
//         else if (money >= 8'd30)
//             set_sig(4'd3);
//         else if (money >= 8'd20)
//             set_sig(4'd2);
//         else if (money >= 8'd10)
//             set_sig(4'd1);
//         else
//             set_sig(4'd0);
//     end
//     else begin
            // BCD()
//     end

// end

// task set_sig(input [3:0] digit)
// begin
//     case(digit) 
//         4'd0:
//         4'd1:
//         4'd2:
//         4'd3:
//         4'd4:
//         4'd5:
//         4'd6:
//         4'd7:
//         4'd8:
//         4'd9:
//         default:
//     endcase
// end
// endtask

// endmodule

module Display_Affordable_Drinks (
    output reg [4-1:0] LED,
    input [9-1:0] money
);

always @(*) begin
    if (money >= 9'd60)
        LED[3:0] = 4'b1111;
    else if (money >= 9'd30)
        LED[3:0] = 4'b0111;
    else if (money >= 9'd25)
        LED[3:0] = 4'b0011;
    else if (money >= 9'd20)
        LED[3:0] = 4'b0001;
    else
        LED[3:0] = 4'b0000;
end

endmodule

module Clock_Divider(
    output div_sig,
    input clk
);

//parameter DIV_TIME = ;

endmodule

module DeBounce_OnePulse (
    output sig_op,
    input sig,
    input clk
);

parameter SIZE = 4;

// Debounce
reg [SIZE-1:0] dff;
reg sig_db;

always @(posedge clk) begin
    dff[SIZE-1:1] <= dff[SIZE-1-1:0];
    dff[0]   <= sig;
end
always @(*) begin
    sig_db = &dff;
end

// OnePulse
OnePulse op (
    .signal_single_pulse(sig_op),
	.signal(sig_db),
	.clock(clk)
);

endmodule