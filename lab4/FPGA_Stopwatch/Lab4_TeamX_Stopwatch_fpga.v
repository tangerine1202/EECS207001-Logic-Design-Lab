`timescale 1ns/1ps

module Stopwatch_fpga (seg, an, start, clk, rst);

input clk;
input rst;
input start;
output [8-1:0] seg; // cg~ca, dp
output [4-1:0] an;

wire decisecond_div_sig;  // 1/10 sec clk (based on original clk is 100M hz)
wire display_div_sig;  // 1/10 sec clk (based on original clk is 100M hz)
wire onepulse_rst;
wire onepulse_start;
// wire [4-1:0] times [4-1:0]; // minutes, 10-seconds, seconds, deciseconds
wire [4-1:0] minutes;
wire [4-1:0] dekaseconds;
wire [4-1:0] seconds;
wire [4-1:0] deciseconds;

ClockDivider #(.DIV(32'b1_000_000)) decisecond_clk_divider (
  .div_sig(decisecond_div_sig),
  .clk(clk)
);

ClockDivider #(.DIV(32'b100_000)) display_clk_divider (
  .div_sig(display_div_sig),
  .clk(clk)
);

OnePulse rst_onepulse (
  .out(onepulse_rst),
  .in(rst),
  .one_pulse_div_sig(decisecond_div_sig),
  .debounce_div_sig(display_div_sig),
  .clk(clk)
);

OnePulse start_onepulse (
  .out(onepulse_start),
  .in(start),
  .one_pulse_div_sig(decisecond_div_sig),
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
  .clk(ckl)
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


// module Stopwatch (minutes, seconds, deciseconds, start, rst, clk);
module Stopwatch (minutes, dekaseconds, seconds, deciseconds, start, rst, div_sig, clk);

parameter WAIT = 2'b00;
parameter COUNT = 2'b01;
parameter RESET = 2'b10;

input clk;
input div_sig;
input rst;
input start;
output reg [4-1:0] minutes;
output reg [4-1:0] dekaseconds;
output reg [4-1:0] seconds;
output reg [4-1:0] deciseconds;
// output reg [4-1:0] minutes; // 0~9
// output reg [6-1:0] seconds; // 0~59
// output reg [4-1:0] deciseconds;  // 0~9

reg [2-1:0] state;
reg [2-1:0] next_state;
// reg [4-1:0] times [4-1:0]; // minutes, 10-seconds, seconds, deciseconds
// reg [4-1:0] next_times [4-1:0];
// wire carrys [4-1:0];

reg [4-1:0] next_minuts;
reg [4-1:0] next_dekaseconds;
reg [4-1:0] next_seconds;
reg [4-1:0] next_deciseconds;
wire is_time_limit;  // if it's 9:59
wire have_minutes_carry;
wire have_dekaseconds_carry;
wire have_seconds_carry;
wire have_deciseconds_carry;

// assign minutes = times[3];
// assign dekaseconds = times[2];
// assign seconds = times[1];
// assign deciseconds = times[0];

// assign is_time_limit = ((times[3] == 4'd9) && (times[2] == 4'd5) && (times[1] == 4'd9) && (times[0] == 4'd9));
// assign carrys[3] = (carrys[3] == 4'd9);
// assign carrys[2] = (carrys[2] == 4'd5);
// assign carrys[1] = (carrys[1] == 4'd9);
// assign carrys[0] = (carrys[0] == 4'd9);

assign is_time_limit = ((minutes == 4'd9) && (dekaseconds == 4'd5) && (seconds == 4'd9) && (deciseconds == 4'd9));
assign have_minutes_carry = (minutes == 4'd9);
assign have_dekaseconds_carry = (dekaseconds == 4'd5);
assign have_seconds_carry = (seconds == 4'd9);
assign have_deciseconds_carry = (deciseconds == 4'd9);

always @(posedge clk) begin
  if (div_sig == 1'b1) begin
    if (rst == 1'b1) begin
      state <= RESET;
      minutes <= 4'b0;
      dekaseconds <= 4'b0;
      seconds <= 4'b0;
      deciseconds <= 4'b0;
      // times[3] <= 4'b0;
      // times[2] <= 4'b0;
      // times[1] <= 4'b0;
      // times[0] <= 4'b0;
    end
    else begin
      state <= next_state;
      minutes <= next_minuts;
      dekaseconds <= next_dekaseconds;
      seconds <= next_seconds;
      deciseconds <= next_deciseconds;
      // times[3] <= next_times[3];
      // times[2] <= next_times[2];
      // times[1] <= next_times[1];
      // times[0] <= next_times[0];
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
        if (is_time_limit == 1'b1)
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
      // next_times[3] = 4'b0;
      // next_times[2] = 4'b0;
      // next_times[1] = 4'b0;
      // next_times[0] = 4'b0;
      next_minuts = 4'b0;
      next_dekaseconds = 4'b0;
      next_seconds = 4'b0;
      next_deciseconds = 4'b0;
    end
    WAIT: begin
      if (is_time_limit == 1'b1) begin
        // next_times[3] = 4'b0;
        // next_times[2] = 4'b0;
        // next_times[1] = 4'b0;
        // next_times[0] = 4'b0;
        next_minuts = 4'b0;
        next_dekaseconds = 4'b0;
        next_seconds = 4'b0;
        next_deciseconds = 4'b0;
      end
      else begin
        // next_times[3] = times[3];
        // next_times[2] = times[1];
        // next_times[1] = times[2];
        // next_times[0] = times[0];
        next_minuts = minutes;
        next_dekaseconds = dekaseconds;
        next_seconds = seconds;
        next_deciseconds = deciseconds;
      end
    end
    COUNT: begin
      // next minutes
      if (have_dekaseconds_carry == 1'b1) begin
        if (have_minutes_carry == 1'b1)
          next_minuts = 4'b0;
          // next_times[3] = 4'b0;
        else
          next_minuts = minutes + 4'b1;
          // next_times[3] =  times[3] + 4'b1;
      end
      else
        next_minuts = minutes;
        // next_times[3] = times[3];

      // next dekaseconds
      if (have_seconds_carry == 1'b1) begin
        if (have_dekaseconds_carry == 1'b1)
          next_dekaseconds =  4'b0;
          // next_times[1] = 4'b0;
        else
          next_dekaseconds =  dekaseconds + 4'b1;
          // next_times[1] = times[1] + 4'b1;
      end
      else
          next_dekaseconds =  dekaseconds;
        // next_times[1] =  times[1];

      // next seconds
      if (have_deciseconds_carry == 1'b1) begin
        if (have_seconds_carry == 1'b1)
          next_seconds =  4'b0;
          // next_times[1] = 4'b0;
        else
          next_seconds =  seconds + 4'b1;
          // next_times[1] = times[1] + 4'b1;
      end
      else
          next_seconds =  seconds;
        // next_times[1] =  times[1];

      // next deciseconds
      if (have_deciseconds_carry == 1'b1)
        next_deciseconds =  4'b0;
        // next_times[0] = 4'b0;
      else
        next_deciseconds = deciseconds + 4'b1;
        // next_times[0] = times[0] + 4'b1;
    end
    default: begin
      next_minuts = 4'b0;
      next_dekaseconds = 4'b0;
      next_seconds = 4'b0;
      next_deciseconds = 4'b0;
      // next_times[3] = 4'b0;
      // next_times[2] = 4'b0;
      // next_times[1] = 4'b0;
      // next_times[0] = 4'b0;
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
output [8-1:0] seg;
output [4-1:0] an;

reg [2-1:0] an_idx;
reg [4-1:0] seg_in;

always @(posedge clk) begin
  if (div_sig == 1'b1) begin
    an_idx <= an_idx + 2'b1;
  end
end

always @(*) begin
  case (an_idx)
    2'd0: seg_in = minutes;
    2'd1: seg_in = dekaseconds;
    2'd2: seg_in = seconds;
    2'd3: seg_in = deciseconds;
    default: seg_in = 7'b0;
  endcase
end

assign an[3] = (an_idx == 2'd3) ? 1'b0 : 1'b1;
assign an[2] = (an_idx == 2'd2) ? 1'b0 : 1'b1;
assign an[1] = (an_idx == 2'd1) ? 1'b0 : 1'b1;
assign an[0] = (an_idx == 2'd0) ? 1'b0 : 1'b1;

// dp
assign seg[0] = (an_idx == 2'd1) ? 1'b0 : 1'b1;

NumToSeg num_to_seg (
  .num(seg_in),
  .seg(seg[7:1])
);

endmodule


module NumToSeg (num, seg);

input [4-1:0] num;
output reg [6:0] seg; // cg~ca, no dp

always @(*) begin
  case (num)
    4'd0: begin seg = 7'b1100000; end
    4'd1: begin seg = 7'b1111100; end
    4'd2: begin seg = 7'b1010010; end
    4'd3: begin seg = 7'b1011000; end
    4'd4: begin seg = 7'b1001100; end
    4'd5: begin seg = 7'b1001001; end
    4'd6: begin seg = 7'b1000001; end
    4'd7: begin seg = 7'b1111100; end
    4'd8: begin seg = 7'b1000000; end
    4'd9: begin seg = 7'b1001000; end
    4'ha: begin seg = 7'b0000100; end
    4'hb: begin seg = 7'b0000001; end
    4'hc: begin seg = 7'b0100011; end
    4'hd: begin seg = 7'b0010000; end
    4'he: begin seg = 7'b0000011; end
    4'hf: begin seg = 7'b0000111; end
    default: begin seg = 7'b0111111; end
  endcase
end

endmodule

/*
only use "posedge orig_clk", don't use 'derived_clk'

ex.
  derived_clk waveform:
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

module OnePulse (out, in, one_pulse_div_sig, debounce_div_sig, clk);

input clk;
input one_pulse_div_sig;
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
  if (one_pulse_div_sig == 1'b1) begin
    out <= debounced_in & !prev_in;
    prev_in <= in;
  end
  else
    out <= out;
    prev_in <= prev_in;
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
    dff[3:1] <= dff[2:0];
    dff[0] <= in;
  end
  else
    dff[3:0] <= dff[3:0];
end

// &: reduction AND
assign out = &dff;

endmodule
