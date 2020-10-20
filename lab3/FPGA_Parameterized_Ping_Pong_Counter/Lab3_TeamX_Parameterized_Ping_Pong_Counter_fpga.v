`timescale 1ns/1ps 

module Parameterized_Ping_Pong_Counter (seg, an, clk, rst_n, enable, flip, max, min);
input clk, rst_n;
input enable;
input flip;
input [4-1:0] max;
input [4-1:0] min;

output [8-1:0] seg; // 0~6: ca~cg  7: dp
output [4-1:0] an;

wire flip_debounced;
wire flip_one_pluse;
wire rst_n_debounced;
wire rst_n_one_pluse;

wire clk_out;  // 0.5 s
wire clk_refresh;  // 1 ms

wire [4-1:0] out;
wire direction;

// Sequential: flip debouncing, one pulse
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

// Sequential: rst_n debouncing, one pluse
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

// Sequential: clock divider
Clock_divider clock_divider(
    .clk_out(clk_out),
    .clk_refresh(clk_refresh),
    .origin_clk(clk),
    .rst_n(rst_n_one_pluse)
);

Ping_pong_counter pppc(
    .out(out), 
    .direction(direction), 
    .clk(clk_out), 
    .rst_n(rst_n_one_pluse), 
    .enable(enable), 
    .flip(flip_one_pluse),
    .max(max), 
    .min(min)
);

// Sequential: select digit to display
Select_Display select_display(
    .seg(seg),
    .an(an),
    .cnt(out),
    .direction(direction),
    .rst_n(rst_n_one_pluse),
    .clk(clk_refresh)
);

endmodule

/** 
 * @output clk_out: The clk for updating ping-pong counter. 
 * @output clk_refresh: The clk for updating 7-segment display. Once clk_refresh trigger, change 
 *                   the display digit. So every 4 clk_refresh, the 7-segment display refresh.
*/ 
module Clock_divider (clk_out, clk_refresh, origin_clk, rst_n);

input origin_clk;
input rst_n;
output clk_out;
output clk_refresh;

parameter OUT_CLK = 50000000;
parameter REFRESH_CLK = 100000;

reg [32-1:0] next_cnt_out;
reg [32-1:0] next_cnt_refresh;
reg [32-1:0] cnt_out;      // 50,000,000 origin_clk => 1 clk_out
reg [32-1:0] cnt_refresh;  // 100,000    origin_clk => 1 clk_refresh 

// Sequential
always @(posedge origin_clk) begin
    if (rst_n == 1'b0) begin
        cnt_out <= 32'b0;
        cnt_refresh <= 32'b0;
    end
    else begin
        if (cnt_out == OUT_CLK) begin
            cnt_out <= 32'b0;
        end
        else begin
            cnt_out <= cnt_out + 32'b1;
        end
        if (cnt_refresh == REFRESH_CLK) begin
            cnt_refresh <= 32'b0;
        end
        else begin
            cnt_refresh <= cnt_refresh + 32'b1;
        end
    end
end

assign clk_out = (cnt_out == OUT_CLK) ? 1'b1 : 1'b0;
assign clk_refresh = (cnt_refresh == REFRESH_CLK) ? 1'b1 : 1'b0;

endmodule

module Select_Display (seg, an, cnt, direction, rst_n, clk);

input clk;
input rst_n;
input [4-1:0] cnt;
input direction;
output [4-1:0] an;
output [8-1:0] seg;

reg [2-1:0] step;
reg [4-1:0] in;
reg sel;  // 0: direction  1: num

// Sequential: an
always @(posedge clk) begin
    if (rst_n == 1'b0)
        step <= 2'b00;
    else
        step <= step + 2'b01;
end

assign an[3] = (step == 2'b11) ? 1'b0 : 1'b1;  // num[1]
assign an[2] = (step == 2'b10) ? 1'b0 : 1'b1;  // num[0]
assign an[1] = (step == 2'b01) ? 1'b0 : 1'b1;  // direction
assign an[0] = (step == 2'b00) ? 1'b0 : 1'b1;  // direction

// Combinational: display segments
always @(*) begin
    if (step == 2'b0 || step == 2'b01) begin
        sel = 1'b0;
        in = direction;
    end
    else if (step == 2'b10) begin
        sel = 1'b1;
        in = (cnt > 10) ? (cnt - 10) : cnt;
    end 
    else begin
        sel = 1'b1;
        in = (cnt > 10) ? 4'b0001 : 4'b0000;
    end 
end

Seven_Segment_Display seven_segment_display(
    .seg(seg),
    .in(in),
    .sel(sel),
    .clk(clk)
);

endmodule

module Seven_Segment_Display (seg, in, sel, clk);

input [4-1:0] in;
input sel;  // 0: direction  1: num
//input rst_n;
input clk;
output reg [8-1:0] seg; // 0~6: ca~cg  7: dp

// reg [8-1:0] next_seg;

// Combinational: next seg
always @(*) begin
    if (sel == 2'b0) begin
        if (in == 4'b1) begin
            seg = 8'b1011100;  // ca, cb, cf 
        end
        else begin
            seg = 8'b11100011;  // cc, cd, ce
        end
    end 
    else begin
        case(in) 
            4'd0: begin seg = 8'b11000000; end
            4'd1: begin seg = 8'b11111001; end
            4'd2: begin seg = 8'b10100100; end
            4'd3: begin seg = 8'b10110000; end
            4'd4: begin seg = 8'b10011001; end
            4'd5: begin seg = 8'b10010010; end
            4'd6: begin seg = 8'b10000010; end
            4'd7: begin seg = 8'b11111000; end
            4'd8: begin seg = 8'b10000000; end
            4'd9: begin seg = 8'b10011111; end
            default: begin seg = 8'b11111111; end
        endcase
    end
end

endmodule

// Debounce submodule
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

// One pluse submodule
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

module Ping_pong_counter (out, direction, clk, rst_n, enable, flip, max, min);

input clk;
input rst_n;
input enable;
input flip;
input [4-1:0] max;
input [4-1:0] min;
output reg direction;
output reg [4-1:0] out;

reg next_direction;
reg [4-1:0] next_out;

// Sequential: direction
always @(posedge clk) begin
    if (rst_n == 1'b0)
        direction <= 1'b1;
    else
        direction <= next_direction;
end

// Sequential: out
always @(posedge clk) begin
    if (rst_n == 1'b0)
        out <= min;
    else 
        out <= next_out;
end

// Combinational: next_direction
always @(*) begin
    if (flip == 1'b1)
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
