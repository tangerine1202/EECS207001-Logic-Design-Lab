`timescale 1ns/1ps
`define MOTOR_STOP 2'b00
`define MOTOR_FORWARD 2'b10
`define MOTOR_BACKWARD 2'b01

module Top(
  input clk,
  input rst,
  input echo,
  input left_signal,
  input right_signal,
  input mid_signal,
  output trig,
  output left_speed,
  output reg [1:0] left,
  output right_speed,
  output reg [1:0] right,
  // debug
  output LED_rst,
  output [1:0] LED_left,
  output [1:0] LED_right,
  output LED_left_speed,
  output LED_right_speed,
  output LED_stop,
  output LED_left_signal,
  output LED_mid_signal,
  output LED_right_signal,
  output [6:0] seg,
  output [3:0] an
);

  wire [19:0] sonic_dis;

  wire rst_op, rst_pb;
  wire stop;
  wire [2:0] sensor_signals;

  debounce d0(rst_pb, rst, clk);
  onepulse d1(rst_pb, clk, rst_op);

  motor A(
    .clk(clk),
    .rst(rst_op),
    .mode(2'b01),  // go straight
    .pwm({left_speed, right_speed})
  );

  sonic_top B(
    .clk(clk),
    .rst(rst_op),
    .Echo(echo),
    .Trig(trig),
    .stop(stop),
    .dis(sonic_dis)
  );

  tracker_sensor C(
    .clk(clk),
    .reset(rst_op),
    .left_signal(left_signal),
    .right_signal(right_signal),
    .mid_signal(mid_signal),
    .state(sensor_signals)
   );

  always @(*) begin
    // TODO: Use left and right to set your pwm
    // if (stop)
    // else
    if (rst_op == 1'b1)
      {left, right} = {`MOTOR_FORWARD, `MOTOR_FORWARD};
    else
      if (stop == 1'b1)
        {left, right} = {`MOTOR_STOP, `MOTOR_STOP};
      else
        if (sensor_signals == 3'b100 || sensor_signals == 3'b110)
            {left, right} = {`MOTOR_STOP, `MOTOR_FORWARD};
        else if (sensor_signals == 3'b001 || sensor_signals == 3'b011)
            {left, right} = {`MOTOR_FORWARD, `MOTOR_STOP};
        else if (sensor_signals == 3'b111)
          {left, right} = {`MOTOR_BACKWARD || `MOTOR_BACKWARD};
        else if (sensor_signals == 3'b000)
          {left, right} = {`MOTOR_FORWARD || `MOTOR_FORWARD};
  end

  // debug
  assign LED_rst = rst;
  assign LED_left = left;
  assign LED_right = right;
  assign LED_left_speed = left_speed;
  assign LED_right_speed = right_speed;
  assign LED_stop = stop;
  assign LED_left_signal = left_signal;
  assign LED_mid_signal = mid_signal;
  assign LED_right_signal = right_signal;
  NumToSeg num2seg (.clk(clk), .num(sonic_dis), .seg(seg), .an(an));

endmodule

module debounce (pb_debounced, pb, clk);
  output pb_debounced;
  input pb;
  input clk;
  reg [4:0] DFF;

  always @(posedge clk) begin
    DFF[4:1] <= DFF[3:0];
    DFF[0] <= pb;
  end
  assign pb_debounced = (&(DFF));
endmodule

module onepulse (PB_debounced, clk, PB_one_pulse);
  input PB_debounced;
  input clk;
  output reg PB_one_pulse;
  reg PB_debounced_delay;

  always @(posedge clk) begin
    PB_one_pulse <= PB_debounced & (! PB_debounced_delay);
    PB_debounced_delay <= PB_debounced;
  end
endmodule

module NumToSeg (clk, num, seg, an);

parameter DIV = 32'd100_000;

input clk;
input [19:0] num;
output reg [6:0] seg; // cg~ca
output reg [3:0] an;

reg [3:0] digit;
reg [1:0] an_idx;
reg [32-1:0] cnt;
wire div_sig;

always @(posedge clk) begin
  if (cnt >= DIV - 32'b1)
    cnt <= 32'b0;
  else
    cnt <= cnt + 32'b1;
end
assign div_sig = (cnt == DIV - 32'b1) ? 1'b1: 1'b0;

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
  if (an_idx == 2'd0)
    digit = num % 10;
  else if (an_idx == 2'd1)
    digit = num / 10;
  else if (an_idx == 2'd2)
    digit = num / 100;
  else if (an_idx == 2'd3)
    digit = num / 1000;
  else
    digit = 4'd0;
end

always @(*) begin
  case (digit)
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
