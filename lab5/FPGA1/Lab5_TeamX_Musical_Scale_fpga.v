`timescale 1ns/1ps

module Musical_Scale_fpga (
    input clk,
    inout PS2_DATA,
    inout PS2_CLK,
    output pmod_1,
    output pmod_2,
    output pmod_4,
    // FIXME: only for test
    input kb_rst
    // output speed_state,
    // output [4:0] tone_idx
  );

  parameter ENTER = 9'b0_0101_1010;
  parameter ENTER_RIGHT = 9'b1_0101_1010;
  parameter KB_0 = 9'b0_0100_0101;
  parameter KB_1 = 9'b0_0001_0110;
  parameter KB_2 = 9'b0_0001_1110;
  parameter KB_0_RIGHT = 9'b0_0111_0000;
  parameter KB_1_RIGHT = 9'b0_0110_1001;
  parameter KB_2_RIGHT = 9'b0_0111_0010;
  parameter DUTY_BEST = 10'd512;

  wire [511:0] key_down;
  wire [8:0] last_change;
  wire been_ready;

  assign pmod_2 = 1'b1;   // no gain (6dB)
  assign pmod_4 = 1'b1;   // turn-on

  reg rst;
  reg kb0_pressed;
  reg kb1_pressed;
  reg kb2_pressed;

  wire speed_state;    // 0: 0.5 sec, 1: 1 sec
  wire beatFreq;       // div_sig for ascending / descending

  wire [4:0] tone_idx;
  wire [31:0] freq;


  KeyboardDecoder key_de (
                    .key_down(key_down),
                    .last_change(last_change),
                    .key_valid(been_ready),
                    .PS2_DATA(PS2_DATA),
                    .PS2_CLK(PS2_CLK),
                    .clk(clk),
                    .rst(kb_rst)
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
            .reset(rst),
            .freq(freq),
            .duty(DUTY_BEST),
            .PWM(pmod_1)
          );

  // pre-process keyboard input
  always @(posedge clk)
  begin
    if (been_ready && key_down[last_change] == 1'b1)
    begin
      rst <= (last_change == ENTER || last_change == ENTER_RIGHT) ? 1'b1 : 1'b0;
      kb0_pressed <= (last_change == KB_0 || last_change == KB_0_RIGHT) ? 1'b1 : 1'b0;
      kb1_pressed <= (last_change == KB_1 || last_change == KB_1_RIGHT) ? 1'b1 : 1'b0;
      kb2_pressed <= (last_change == KB_2 || last_change == KB_2_RIGHT) ? 1'b1 : 1'b0;
    end
    else
    begin
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
    output reg speed_state
  );

  always @(posedge clk)
  begin
    if (rst == 1'b1)
      speed_state <= 1'b0;
    else
      if (ctrl == 1'b1)
        speed_state <= ~speed_state;
      else
        speed_state <= speed_state;
  end

endmodule


module ClockDivider (
    input clk,
    input rst,
    input speed_state,
    output reg div_sig
  );

  parameter [31:0] S0_FREQ = 32'd_50_000_000;   // 0.5 sec
  parameter [31:0] S1_FREQ = 32'd100_000_000;   // 1   sec

  reg [31:0] cnt;

  // counter
  always @(posedge clk)
  begin
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

  // div_sig (output)
  always @(*)
  begin
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


module ToneController (
    input clk,
    input rst,
    input beatFreq,
    input asc_ctrl,
    input dsc_ctrl,
    output reg [4:0] tone_idx
  );

  parameter HIGHEST_TONE = 5'd28;
  parameter LOWEST_TONE = 5'd0;

  reg [4:0] next_tone_idx;
  reg ascend_state;
  reg next_ascend_state;

  // tone (update with div_sig)
  always @(posedge clk)
  begin
    if (rst == 1'b1)
      tone_idx <= 5'd0;
    else
      if (beatFreq == 1'b1)
        tone_idx <= next_tone_idx;
      else
        tone_idx <= tone_idx;
  end

  // ascend (update with clk)
  always @(posedge clk)
  begin
    if (rst == 1'b1)
      ascend_state <= 1'b1;
    else
      ascend_state <= next_ascend_state;
  end

  // next ascend
  always @(*)
  begin
    if (asc_ctrl == 1'b1)
      next_ascend_state = 1'b1;
    else
      if (dsc_ctrl == 1'b1)
        next_ascend_state = 1'b0;
      else
        next_ascend_state = ascend_state;
  end

  // next tone
  always @(*)
  begin
    if (ascend_state == 1'b1)
    begin
      if (tone_idx == HIGHEST_TONE)
        next_tone_idx = tone_idx;
      else
        next_tone_idx = tone_idx + 5'b1;
    end
    else
    begin
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

  parameter NM1 = 32'd262; // C_freq
  parameter NM2 = 32'd294; // D_freq
  parameter NM3 = 32'd330; // E_freq
  parameter NM4 = 32'd349; // F_freq
  parameter NM5 = 32'd392; // G_freq
  parameter NM6 = 32'd440; // A_freq
  parameter NM7 = 32'd494; // B_freq
  parameter NM0 = 32'd10000; // obvious high freq tone
  always @(*)
  begin
    case (tone_idx)
      5'd0:
        tone = NM1;  // C4
      5'd1:
        tone = NM2;
      5'd2:
        tone = NM3;
      5'd3:
        tone = NM4;
      5'd4:
        tone = NM5;
      5'd5:
        tone = NM6;
      5'd6:
        tone = NM7;
      5'd7:
        tone = NM1 << 1;  // C5
      5'd8:
        tone = NM2 << 1;
      5'd9:
        tone = NM3 << 1;
      5'd10:
        tone = NM4 << 1;
      5'd11:
        tone = NM5 << 1;
      5'd12:
        tone = NM6 << 1;
      5'd13:
        tone = NM7 << 1;
      5'd14:
        tone = NM1 << 2;  // C6
      5'd15:
        tone = NM2 << 2;
      5'd16:
        tone = NM3 << 2;
      5'd17:
        tone = NM4 << 2;
      5'd18:
        tone = NM5 << 2;
      5'd19:
        tone = NM6 << 2;
      5'd20:
        tone = NM7 << 2;
      5'd21:
        tone = NM1 << 3;  // C7
      5'd22:
        tone = NM2 << 3;
      5'd23:
        tone = NM3 << 3;
      5'd24:
        tone = NM4 << 3;
      5'd25:
        tone = NM5 << 3;
      5'd26:
        tone = NM6 << 3;
      5'd27:
        tone = NM7 << 3;
      5'd28:
        tone = NM1 << 4;  // C8
      default:
        tone = NM0;
    endcase
  end

endmodule
