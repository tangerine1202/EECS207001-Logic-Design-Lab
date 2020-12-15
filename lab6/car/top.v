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
  output wire stop
);

  wire rst_op, rst_pb;
  wire [2:0] sensor_state;
  debounce d0(rst_pb, rst, clk);
  onepulse d1(rst_pb, clk, rst_op);

  motor A(
    .clk(clk),
    .rst(rst_op),
    // .mode(),
    .pwm({left_speed, right_speed})
  );

  sonic_top B(
    .clk(clk),
    .rst(rst_op),
    .Echo(echo),
    .Trig(trig),
    .stop(stop)
  );

  tracker_sensor C(
    .clk(clk),
    .reset(rst_op),
    .left_signal(left_signal),
    .right_signal(right_signal),
    .mid_signal(mid_signal),
    .state(sensor_state)
   );

  always @(*) begin
    // TODO: Use left and right to set your pwm
    // if (stop)
      // {left, right} = {`MOTOR_STOP, `MOTOR_STOP};
    // else
    if (rst_op == 1'b1)
      {left, right} = {`MOTOR_FORWARD, `MOTOR_FORWARD};
    else
      {left, right} = {`MOTOR_FORWARD, `MOTOR_FORWARD};
  end

  // debug
  assign LED_rst = rst;
  assign LED_left = left;
  assign LED_right = right;
  assign LED_left_speed = left_speed;
  assign LED_right_speed = right_speed;

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

