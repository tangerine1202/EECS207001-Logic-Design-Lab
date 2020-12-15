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
  output reg [1:0] right
);

  wire Rst_n, rst_pb;
  debounce d0(rst_pb, rst, clk);
  onepulse d1(rst_pb, clk, Rst_n);

  motor A(
    .clk(clk),
    .rst(rst),
    // .mode(),
    .pwm({left_speed, right_speed})
  );

  sonic_top B(
    .clk(clk),
    .rst(rst),
    .Echo(echo),
    .Trig(trig),
    .stop(stop)
  );

  tracker_sensor C(
    .clk(clk),
    .reset(rst),
    .left_signal(left_signal),
    .right_signal(right_signal),
    .mid_signal(mid_signal),
    .state(sensor_state)
   );

  always @(*) begin
    // TODO: Use left and right to set your pwm
    if (stop)
      {left, right} = {`MOTOR_STOP, `MOTOR_STOP};
    else
      {left, right} = {`MOTOR_FORWARD, `MOTOR_FORWARD};
  end

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

