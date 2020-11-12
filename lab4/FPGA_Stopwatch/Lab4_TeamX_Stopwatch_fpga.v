`timescale 1ns/1ps

module Stopwatch_fpga (seg, an, start, clk, rst);

input clk;
input rst;
input start;
output [8-1:0] seg; // [7]: dp, [6:0]: cg~ca
output [4-1:0] an;

wire decisecond_div_sig;  // 0.1 sec clk (based on original clk is 100M hz)
wire display_div_sig;
wire onepulse_rst;
wire onepulse_start;
wire [4-1:0] minutes;
wire [4-1:0] dekaseconds; // 10 sec
wire [4-1:0] seconds;
wire [4-1:0] deciseconds; // 0.1 sec


ClockDivider #(.DIV(32'd10_000_000)) decisecond_clk_divider (
  .div_sig(decisecond_div_sig),
  .clk(clk)
);

ClockDivider #(.DIV(32'd100_000)) display_clk_divider (
  .div_sig(display_div_sig),
  .clk(clk)
);

OnePulse rst_onepulse (
  .out(onepulse_rst),
  .in(rst),
  .onepulse_div_sig(decisecond_div_sig),
  .debounce_div_sig(display_div_sig),
  .clk(clk)
);

OnePulse start_onepulse (
  .out(onepulse_start),
  .in(start),
  .onepulse_div_sig(decisecond_div_sig),
  .debounce_div_sig(display_div_sig),
  .clk(clk)
);

Stopwatch stopwatch (
  .minutes(minutes),
  .dekaseconds(dekaseconds),
  .seconds(seconds),
  .deciseconds(deciseconds),
  .start(onepulse_start),
  .rst(onepulse_rst),
  .div_sig(decisecond_div_sig),
  .clk(clk)
);

SegDisplay seg_display (
  .seg(seg),
  .an(an),
  .minutes(minutes),
  .dekaseconds(dekaseconds),
  .seconds(seconds),
  .deciseconds(deciseconds),
  .div_sig(display_div_sig),
  .clk(clk)
);

endmodule


module Stopwatch (minutes, dekaseconds, seconds, deciseconds, start, rst, div_sig, clk);

parameter RESET = 2'b00;
parameter WAIT = 2'b01;
parameter COUNT = 2'b10;

input clk;
input div_sig;
input rst;
input start;
output reg [4-1:0] minutes;
output reg [4-1:0] dekaseconds;
output reg [4-1:0] seconds;
output reg [4-1:0] deciseconds;

reg [2-1:0] state;
reg [2-1:0] next_state;

reg [4-1:0] next_minutes;
reg [4-1:0] next_dekaseconds;
reg [4-1:0] next_seconds;
reg [4-1:0] next_deciseconds;

wire is_minutes_carry;
wire is_dekaseconds_carry;
wire is_seconds_carry;
wire is_deciseconds_carry;


assign is_deciseconds_carry = (deciseconds == 4'd9);
assign is_seconds_carry = ((seconds == 4'd9) && is_deciseconds_carry);
assign is_dekaseconds_carry = ((dekaseconds == 4'd5) && is_seconds_carry  && is_deciseconds_carry);
assign is_minutes_carry = ((minutes == 4'd9) && is_dekaseconds_carry && is_seconds_carry && is_deciseconds_carry);

// SC: state transition & update timer
always @(posedge clk) begin
  if (div_sig == 1'b1) begin
    if (rst == 1'b1) begin
      state <= RESET;
      minutes <= 4'b0;
      dekaseconds <= 4'b0;
      seconds <= 4'b0;
      deciseconds <= 4'b0;
    end
    else begin
      state <= next_state;
      minutes <= next_minutes;
      dekaseconds <= next_dekaseconds;
      seconds <= next_seconds;
      deciseconds <= next_deciseconds;
    end
  end
  else begin
      state <= state;
      minutes <= minutes;
      dekaseconds <= dekaseconds;
      seconds <= seconds;
      deciseconds <= deciseconds;
  end
end

// CC: next state
always @(*) begin
  case (state)
    RESET: begin
      if (start == 1'b1)
        next_state = COUNT;
      else
        next_state = RESET;
    end
    WAIT: begin
      if (start == 1'b1)
        next_state = COUNT;
      else
        next_state = WAIT;
    end
    COUNT: begin
      if (start == 1'b1)
        next_state = WAIT;
      else begin
        if (is_minutes_carry == 1'b1)
          next_state = WAIT;
        else
          next_state = COUNT;
      end
    end
    default:
      next_state = RESET;
  endcase
end

// CC: next minutes, dekaseconds, seconds, deciseconds
always @(*) begin
  case (next_state)
    RESET: begin
      next_minutes = 4'b0;
      next_dekaseconds = 4'b0;
      next_seconds = 4'b0;
      next_deciseconds = 4'b0;
    end
    WAIT: begin
      if (is_minutes_carry == 1'b1) begin
        next_minutes = 4'b0;
        next_dekaseconds = 4'b0;
        next_seconds = 4'b0;
        next_deciseconds = 4'b0;
      end
      else begin
        next_minutes = minutes;
        next_dekaseconds = dekaseconds;
        next_seconds = seconds;
        next_deciseconds = deciseconds;
      end
    end
    COUNT: begin
      // next deciseconds
      if (is_deciseconds_carry == 1'b1)
        next_deciseconds =  4'b0;
      else
        next_deciseconds = deciseconds + 4'b1;

      // next seconds
      if (is_deciseconds_carry == 1'b1) begin
        if (is_seconds_carry == 1'b1)
          next_seconds =  4'b0;
        else
          next_seconds =  seconds + 4'b1;
      end
      else
          next_seconds =  seconds;

      // next dekaseconds
      if (is_seconds_carry == 1'b1) begin
        if (is_dekaseconds_carry == 1'b1)
          next_dekaseconds =  4'b0;
        else
          next_dekaseconds =  dekaseconds + 4'b1;
      end
      else
          next_dekaseconds =  dekaseconds;

      // next minutes
      if (is_dekaseconds_carry == 1'b1) begin
        if (is_minutes_carry == 1'b1)
          next_minutes = 4'b0;
        else
          next_minutes = minutes + 4'b1;
      end
      else
        next_minutes = minutes;
    end
    default: begin
      next_minutes = 4'b0;
      next_dekaseconds = 4'b0;
      next_seconds = 4'b0;
      next_deciseconds = 4'b0;
    end
  endcase
end

endmodule


module SegDisplay (seg, an, minutes, dekaseconds, seconds, deciseconds, div_sig, clk);

input clk;
input div_sig;
input [4-1:0] minutes;
input [4-1:0] dekaseconds;
input [4-1:0] seconds;
input [4-1:0] deciseconds;
output [8-1:0] seg;   // [7]: dp, [6:0]: cg~ca
output [4-1:0] an;

reg [2-1:0] an_idx;
reg [4-1:0] num;

always @(posedge clk) begin
  if (div_sig == 1'b1)
    an_idx <= an_idx + 2'b1;
  else
    an_idx <= an_idx;
end

assign an[3] = (an_idx == 2'd3) ? 1'b0 : 1'b1;
assign an[2] = (an_idx == 2'd2) ? 1'b0 : 1'b1;
assign an[1] = (an_idx == 2'd1) ? 1'b0 : 1'b1;
assign an[0] = (an_idx == 2'd0) ? 1'b0 : 1'b1;

always @(*) begin
  case (an_idx)
    2'd3: num = minutes;
    2'd2: num = dekaseconds;
    2'd1: num = seconds;
    2'd0: num = deciseconds;
    default: num = 4'he;
  endcase
end

// dp
assign seg[7] = (an_idx == 2'd1) ? 1'b0 : 1'b1;

NumToSeg num_to_seg (
  .num(num),
  .seg(seg[6:0])
);

endmodule


module NumToSeg (num, seg);

input [4-1:0] num;
output reg [6:0] seg; // cg~ca

always @(*) begin
  case (num)
    4'd0: begin seg = 7'b1000000; end
    4'd1: begin seg = 7'b1111001; end
    4'd2: begin seg = 7'b0100100; end
    4'd3: begin seg = 7'b0110000; end
    4'd4: begin seg = 7'b0011001; end
    4'd5: begin seg = 7'b0010010; end
    4'd6: begin seg = 7'b0000010; end
    4'd7: begin seg = 7'b1111000; end
    4'd8: begin seg = 7'b0000000; end
    4'd9: begin seg = 7'b0010000; end
    4'ha: begin seg = 7'b0001000; end
    4'hb: begin seg = 7'b0000011; end
    4'hc: begin seg = 7'b1000110; end
    4'hd: begin seg = 7'b0100001; end
    4'he: begin seg = 7'b0000110; end
    4'hf: begin seg = 7'b0001110; end
    default: begin seg = 7'b1111111; end
  endcase
end

endmodule

/*
only use "posedge orig_clk", don't use 'posedge derived_clk'

ex.
  div_sig waveform:
  _|-|_________|-|_________|-|_________|-|____

  always @(posedge clk) begin
    if (div_sig == 1'b1)
      op...
    else
      op...
  end
*/
module ClockDivider (div_sig, clk);

parameter DIV = 32'd1_000_000;

input clk;
output div_sig;

reg [32-1:0] cnt;

always @(posedge clk) begin
  if (cnt >= DIV - 32'b1)
    cnt <= 32'b0;
  else
    cnt <= cnt + 32'b1;
end

assign div_sig = (cnt == DIV - 32'b1) ? 1'b1: 1'b0;

endmodule


module OnePulse (out, in, onepulse_div_sig, debounce_div_sig, clk);

input clk;
input onepulse_div_sig;
input debounce_div_sig;
input in;
output reg out;

wire debounced_in;
reg prev_in;

Debounce #(.SIZE(4)) debounce (
  .out(debounced_in),
  .in(in),
  .div_sig(debounce_div_sig),
  .clk(clk)
);

always @(posedge clk) begin
  if (onepulse_div_sig == 1'b1) begin
    out <= (debounced_in & (!prev_in));
    prev_in <= in;
  end
  else begin
    out <= out;
    prev_in <= prev_in;
  end
end

endmodule


module Debounce (out, in, div_sig, clk);

parameter SIZE = 4;

input clk;
input div_sig;
input in;
output out;

reg [SIZE-1:0] dff;

always @(posedge clk) begin
  if (div_sig == 1'b1) begin
    dff[SIZE-1:1] <= dff[SIZE-2:0];
    dff[0] <= in;
  end
  else begin
    dff[SIZE-1:0] <= dff[SIZE-1:0];
  end
end

// reduction AND
assign out = &dff;

endmodule
