`timescale 1ns/1ps

module FPGA_1 (
  input clk,
  input PS2_DATA,
  input PS2_CLK,
  output pmod_1,
  output pmod_2,
  output pmod_4
  // FIXME: only for test
);

parameter [8:0] ENTER = 9'b0_0101_0100;
parameter [8:0] KB_O = 9'b0_0100_0101;
parameter [8:0] KB_1 = 9'b0_0001_0110;
parameter [8:0] KB_2 = 9'b0_0001_1110;
parameter [8:0] KB_O_RIGHT = 9'b0_0111_0000;
parameter [8:0] KB_1_RIGHT = 9'b0_0110_1001;
parameter [8:0] KB_2_RIGHT = 9'b0_0111_0010;
parameter [10:0] DUTY_BEST = 10'd512;

wire [511:0] key_down;
wire [8:0] last_change;
wire been_ready;

reg rst;
reg kb0_pressed;
reg kb1_pressed;
reg kb2_pressed;

reg speed_state;  // 0: 0.5 sec, 1: 1 sec
reg beatFreq;

reg [4:0] tone_idx;
reg [31:0] freq;

KeyboardDecoder key_de (
  .key_down(key_down),
  .last_change(last_change),
  .key_valid(been_ready),
  .PS2_DATA(PS2_DATA),
  .PS2_CLK(PS2_CLK),
  .clk(clk)
  // .rst(rst)  // FIXME: conflict with impl rst
);

SpeedController speed_controller (
  .clk(clk),
  .rst(rst),
  .ctrl(kb2_pressed),
  .speed_state(speed_state)
);

ClockDivider clock_divider (
  .clk(clk),
  .rst(rst),
  .speed_state(speed_state),
  .div_sig(beatFreq)
);
// BeatSpeedGen bt_speed_gen (
  // .clk(clk),
  // .rst(rst),
  // .speed_state(speed_state),
  // .duty(32'b1),   // div_sig mode
  // .PWM(beatFreq)
// );

ToneController tone_controller (
  .clk(clk),
  .rst(rst),
  .beatFreq(beatFreq),
  .asc_ctrl(kb0_pressed),
  .dsc_ctrl(kb1_pressed),
  .tone_idx(tone_idx)
);

ToneIdx2Beat tone_to_beat (
  .tone_idx(tone_idx),
  .tone(freq)
);

PWM_gen tone_gen (
  .clk(clk),
  .rst(rst),
  .freq(freq),
  .duty(DUTY_BEST),
  .PWM(PWM)
);

// preprocess kb input
always @(posedge clk) begin
  if (been_ready && key_down[last_change] == 1'b1) begin
    if (last_change == ENTER)                             rst <= 1'b1;
    else                                                  rst <= 1'b0;
    if (last_change == KB_0 || last_change == KB_0_RIGHT) kb0_pressed <= 1'b1;
    else                                                  kb0_pressed <= 1'b0;
    if (last_change == KB_1 || last_change == KB_1_RIGHT) kb1_pressed <= 1'b1;
    else                                                  kb1_pressed <= 1'b0;
    if (last_change == KB_2 || last_change == KB_2_RIGHT) kb2_pressed <= 1'b1;
    else                                                  kb2_pressed <= 1'b0;
  end
  else begin
    rst <= 1'b0;
    kb0_pressed <= 1'b0;
    kb1_pressed <= 1'b0;
    kb2_pressed <= 1'b0;
  end
end

endmodule


module SpeedController (
  input clk,
  input rst,
  input ctrl,
  output speed_state
);

always @(posedge clk) begin
  if (rst == 1'b1)
    speed_state <= 1'b0;
  else
    if (ctrl == 1'b1)
      speed_state <= ~speed_state;
    else
      speed_state <= speed_state;
end

endmodule


module ToneController (
  input clk,
  input rst,
  input asc_ctrl,
  input dsc_ctrl,
  input beatFreq,
  output tone_idx
);

parameter HIGHEST_TONE = 5'd29;  // TODO: check me
parameter LOWEST_TONE = 5'd0;  // TODO: check me

reg [4:0] tone_idx;   // TODO: check me
reg [4:0] next_tone_idx;
reg ascend_state;
reg next_ascend_state;

// tone
always @(posedge clk) begin
  if (rst == 1'b1)
    tone_idx <= 5'd0;
  else
    if (beatFreq == 1'b1)
      tone_idx <= next_tone_idx;
    else
      tone_idx <= tone_idx;
end

// ascend
always @(posedge clk) begin
  if (rst == 1'b1)
    ascend_state <= 1'b1;
  else
    ascend_state <= next_ascend_state;
end

// next_ascend
always @(*) begin
  if (asc_ctrl == 1'b1)
    next_ascend_state = 1'b1;
  else
    if (des_ctrl = 1'b1)
      next_ascend_state = 1'b0;
    else
      next_ascend_state = ascend_state;
end

// next_state
always @(*) begin
  if (ascend_state == 1'b1) begin
    if (tone_idx == HIGHEST_TONE)
      next_tone_idx = tone_idx;
    else
      next_tone_idx = tone_idx + 5'b1;
  end
  else begin
    if (tone_idx == LOWEST_TONE)
      next_tone_idx = tone_idx;
    else
      next_tone_idx = tone_idx - 5'b1;
  end
end

endmodule


module ToneIdx2Beat (
  input [4:0] tone_idx,
  output reg [31:0] tone
);

parameter NM1 32'd262 // C_freq
parameter NM2 32'd294 // D_freq
parameter NM3 32'd330 // E_freq
parameter NM4 32'd349 // F_freq
parameter NM5 32'd392 // G_freq
parameter NM6 32'd440 // A_freq
parameter NM7 32'd494 // B_freq
parameter NM0 32'd20000 //FIXME: slience (over freq.) (may change to some obvious tone)

always @(*) begin
  case (tone_idx)
    4'd0:  tone = NM1;  // TODO: check me
    4'd1:  tone = NM2;
    4'd2:  tone = NM3;
    4'd3:  tone = NM4;
    4'd4:  tone = NM5;
    4'd5:  tone = NM6;
    4'd6:  tone = NM7;
    4'd7:  tone = NM1 << 1;
    4'd8:  tone = NM2 << 1;
    4'd9:  tone = NM3 << 1;
    4'd10: tone = NM4 << 1;
    4'd11: tone = NM5 << 1;
    4'd12: tone = NM6 << 1;
    4'd13: tone = NM7 << 1;
    4'd14: tone = NM1 << 2;
    4'd15: tone = NM2 << 2;
    4'd17: tone = NM3 << 2;
    4'd18: tone = NM4 << 2;
    4'd19: tone = NM5 << 2;
    4'd20: tone = NM6 << 2;
    4'd21: tone = NM7 << 2;
    4'd22: tone = NM1 << 3;
    4'd23: tone = NM2 << 3;
    4'd24: tone = NM3 << 3;
    4'd25: tone = NM4 << 3;
    4'd27: tone = NM5 << 3;
    4'd28: tone = NM6 << 3;
    4'd29: tone = NM7 << 3;
    default: tone = NM0;
  endcase
end

endmodule


// FIXME: duty is not precise enought to generate div_sig
module BeatSpeedGen (
  input clk,
  input rst,
  input speed_state,
  input [9:0] duty,
  output PWM
);

parameter [31:0] S0_FREQ = 32'd2;   // 0.5 sec
parameter [31:0] S1_FREQ = 32'd1;   // 1   sec

wire [31:0] freq = (speed_state == 1'b0) ? S0_FREQ : S1_FREQ;

PWM_gen btSpeedGen bt_speed_gen (
  .clk(clk),
  .reset(rst),
  .freq(freq),
  .duty(duty),
  .PWM(PWM)
);

endmodule

module ClockDivider (
  input clk,
  input rst,
  input speed_state,
  output div_sig
);

parameter [31:0] S0_FREQ = 32'd_50_000_000;   // 0.5 sec
parameter [31:0] S1_FREQ = 32'd100_000_000;   // 1   sec

reg [31:0] cnt;

always @(posedge clk) begin
  if (rst == 1'b1)
    cnt <= 32'b0;
  else
    if (speed_state == 1'b0)
      if (cnt >= S0_FREQ - 32'b1)
        cnt <= 32'b0;
      else
        cnt <= cnt + 32'b1;
    else
      if (cnt >= S1_FREQ - 32'b1)
        cnt <= 32'b0;
      else
        cnt <= cnt + 32'b1;
end

always @(*) begin
  if (speed_state == 1'b0)
    if (cnt >= S0_FREQ - 32'b1)
      div_sig = 1'b1;
    else
      div_sig = 1'b0;
  else
    if (cnt >= S1_FREQ - 32'b1)
      div_sig = 1'b1;
    else
      div_sig = 1'b0;
end

endmodule