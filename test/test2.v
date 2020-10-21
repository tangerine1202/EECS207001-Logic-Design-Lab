`timescale 1ns/1ps 

module Parameterized_Ping_Pong_Counter (
    seg, 
    an, 
    clk, 
    enable,         
    rst,
    flip,
    max, 
    min,
    // debug_an,
    // debug_out,
    // clk_out,
    // clk_refresh
);
input clk;
input rst;
input enable;
input flip;
input [4-1:0] max;
input [4-1:0] min;
output [8-1:0] seg; // 0~6: ca~cg  7: dp
output [4-1:0] an;


wire rst_n;
assign rst_n = !rst;

// wire [4-1:0] debug_an_n;
// output [4-1:0] debug_an;
// not debug_an_n0 [4-1:0] (debug_an_n, an);
// not debug_an0 [4-1:0] (debug_an, debug_an_n);

wire flip_debounced;
wire flip_one_pulse;
wire rst_n_debounced;
wire rst_n_one_pulse;

wire [4-1:0] out;
wire direction;

wire clk_out;
wire clk_refresh;
// output clk_out;
// output clk_refresh;


// Sequential: clock divider
Clock_divider clock_divider(
    .clk_out(clk_out),
    .clk_refresh(clk_refresh),
    .origin_clk(clk)
);

// Sequential: flip debouncing, one pulse
Debounce debounce_flip (
   .pb_debounced(flip_debounced),
   .pb(flip),
   .clk(clk_refresh)
);
One_pulse one_pulse_flip (
   .pb_one_pulse(flip_one_pulse),
   .pb_debounced(flip_debounced),
   .clk(clk_refresh)
);
// Sequential: rst_n debouncing, one pulse
Debounce_n debounce_rst_n (
   .pb_debounced(rst_n_debounced),
   .pb(rst_n),
   .clk(clk_refresh)
);
One_pulse_n one_pulse_rst_n (
   .pb_one_pulse(rst_n_one_pulse),
   .pb_debounced(rst_n_debounced),
   .clk(clk_refresh)
);


output [4-1:0] debug_out;
assign debug_out = out;
Ping_pong_counter pppc(
    .out(out), 
    .direction(direction), 
    .clk(clk_out), 
    .rst_n(rst_n_one_pulse), 
    .enable(enable), 
    .flip(flip_one_pulse),
    .max(max), 
    .min(min)
);


// Sequential: select digit to display
Select_Display select_display(
    .seg(seg),
    .an(an),
    .clk(clk_refresh),
    .cnt(out),
    .direction(direction)
);

endmodule


/** 
 * @output clk_out: The clk for updating ping-pong counter. 1 clk / 0.5s
 * @output clk_refresh: The clk for updating 7-segment display. Once clk_refresh trigger, change 
 *                   the display digit. So every 4 clk_refresh, the 7-segment display refresh.
 *                   1 clk / 1 ms
*/ 
module Clock_divider (clk_out, clk_refresh, origin_clk);

input origin_clk;
output clk_out;
output clk_refresh;

parameter CLK_PER_OUT = 50_000_000 - 1;     // 1M clk / sec
parameter CLK_PER_REFRESH = 10_000 - 1;  // 1M clk / sec

reg [32-1:0] cnt_out;      // origin_clk => 1 clk_out
reg [32-1:0] cnt_refresh;  // origin_clk => 1 clk_refresh 

// Sequential
always @(posedge origin_clk) begin
    if (cnt_out == CLK_PER_OUT) begin
        cnt_out <= 32'b0;
    end
    else begin
        cnt_out <= cnt_out + 32'b1;
    end
end

always @(posedge origin_clk) begin
    if (cnt_refresh == CLK_PER_REFRESH) begin
        cnt_refresh <= 32'b0;
    end
    else begin
        cnt_refresh <= cnt_refresh + 32'b1;
    end
end

assign clk_out = (cnt_out == CLK_PER_OUT) ? 1'b1 : 1'b0;
assign clk_refresh = (cnt_refresh == CLK_PER_REFRESH) ? 1'b1 : 1'b0;

endmodule



module Select_Display (
    seg, 
    an, 
    cnt, 
    direction, 
    clk
);

input clk;
input [4-1:0] cnt;
input direction;
output [4-1:0] an;
output [8-1:0] seg;

// FIXME: 'an_idx' should be 2bit, but it doesn't work, idk why.
//        and 3bits work, so don't touch it.
reg [2-1:0] an_idx;  // index of current updating an
reg [4-1:0] in;
reg in_type;  // 0: direction  1: out 


// Sequential: index of current updating an 
always @(posedge clk) begin
    if (an_idx == 2'b11) begin
        an_idx <= 2'b00;
    end
    else begin
        an_idx <= an_idx + 2'b01;
    end
end

assign an[3] = (an_idx == 2'b11) ? 1'b0 : 1'b1;  // out[1]
assign an[2] = (an_idx == 2'b10) ? 1'b0 : 1'b1;  // out[0]
assign an[1] = (an_idx == 2'b01) ? 1'b0 : 1'b1;  // direction
assign an[0] = (an_idx == 2'b00) ? 1'b0 : 1'b1;  // direction

// Combinational: display segments
always @(*) begin
    if (an_idx == 2'b10) begin
        in_type = 1'b1;
        in = (cnt >= 4'd10) ? (cnt - 4'd10) : cnt;
    end 
    else if (an_idx == 2'b11) begin
        in_type = 1'b1;
        in = (cnt >= 4'd10) ? 4'b0001 : 4'b0000;
    end
    else begin
        in_type = 1'b0;
        in = {3'b0, direction};
    end
end

Seven_Segment_Display seven_segment_display(
    .seg(seg),
    .in(in),
    .in_type(in_type)
);

endmodule

module Seven_Segment_Display (seg, in, in_type); 

input [4-1:0] in;
input in_type;  // 0: direction  1: out 
output reg [8-1:0] seg; // 0~6: ca~cg  7: dp

// Combinational: next seg
always @(*) begin
    if (in_type == 1'b0) begin
        if (in == 4'b1) begin
            seg = 8'b11011100;  // ca, cb, cf 
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
            4'd9: begin seg = 8'b10010000; end
            // dot stand for unknown 'in'
            4'ha: begin seg = 8'b00001000; end
            4'hb: begin seg = 8'b00000011; end
            4'hc: begin seg = 8'b01000110; end
            4'hd: begin seg = 8'b00100001; end
            4'he: begin seg = 8'b00000110; end
            4'hf: begin seg = 8'b00001110; end
            default: begin seg = 8'b01111111; end
        endcase
    end
end

endmodule



// Debounce submodule
module Debounce (pb_debounced, pb, clk);

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

// Debounce_n submodule
module Debounce_n (pb_debounced, pb, clk);

input pb;
input clk;
output pb_debounced;

reg [4-1:0] dff;

always @(posedge clk) begin
    dff[3:1] <= dff[2:0];
    dff[0] <= pb;
end

assign pb_debounced = (dff == 4'b0000) ? 1'b0 : 1'b1;

endmodule


// One pulse submodule
module One_pulse (pb_one_pulse, pb_debounced, clk);

input pb_debounced;
input clk;
output reg pb_one_pulse;

reg pb_debounced_delay;

always @(posedge clk) begin
    pb_one_pulse <= pb_debounced & (!pb_debounced_delay);
    pb_debounced_delay <= pb_debounced;
end

endmodule

// One pulse_n submodule
module One_pulse_n (pb_one_pulse, pb_debounced, clk);

input pb_debounced;
input clk;
output reg pb_one_pulse;

reg pb_debounced_delay;

always @(posedge clk) begin
    pb_one_pulse <= pb_debounced | (!pb_debounced_delay);
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
always @(posedge clk or negedge rst_n or posedge flip) begin
    if (rst_n == 1'b0) begin
        direction <= 1'b1;
    end
    else begin
        if (flip == 1'b1) begin
            direction <= !direction;
        end    
        else begin
            direction <= next_direction;
        end
    end
end

// Sequential: out
always @(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        out <= min;
    end
    else begin
        out <= next_out;
    end
end

// Combinational: next_direction
always @(*) begin
    if (enable) begin 
        if (out == min) begin
            next_direction = 1'b1;
        end
        else if (out == max) begin
            next_direction = 1'b0;
        end
        else begin
            next_direction = direction;
        end
    end
    else begin
        next_direction = direction;
    end
end

// Combinational: next_out
always @(*) begin
    if (enable) begin
        if (max > min) begin
            if (next_direction == 1'b1 && (out < max)) begin
                next_out = out + 4'b0001;
            end
            else if (next_direction == 1'b0 && (out > min)) begin
                next_out = out - 4'b0001;
            end
            else begin
                next_out = out;
            end
        end
        else begin
            next_out = out;
        end
    end 
    else begin
        next_out = out;
    end
end
endmodule
