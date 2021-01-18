// Modified the code from Lab6
`define MOTOR_STOP 2'b00
`define MOTOR_FORWARD 2'b01
`define MOTOR_BACKWARD 2'b10

module Motor #(
    parameter SIZE = 16,
    parameter MOTOR_PWM_OFFSET = 16'd400    // Offset of motor pwm
) (
  input clk,
  input rst,
  input [SIZE-1:0] motorPower,
  output reg [1:0] leftDirection,
  output reg [1:0] rightDirection,
  output leftPwm,
  output rightPwm,
  // debug
  output [9:0] debugDuty
);

  wire isPowerPositive;
  wire [SIZE-1:0] absOfPower;
  reg [9:0] duty;
  reg [9:0] next_duty;


  motor_pwm m0(
    .clk(clk),
    .reset(rst),
    .duty(duty),
    .pmod_1(leftPwm)
  );
  motor_pwm m1(
    .clk(clk),
    .reset(rst),
    .duty(duty),
    .pmod_1(rightPwm)
  );

  assign isPowerPositive = (motorPower[SIZE-1] == 1'b1) ? 1'd0 : 1'd1;
  assign absOfPower = (isPowerPositive) ? motorPower : -motorPower;

  // Use sign of motorPower to control the direction
  always @(posedge clk) begin
    if (rst == 1'b1) begin
      duty <= 10'd0;
      leftDirection <= `MOTOR_STOP;
      rightDirection <= `MOTOR_STOP;
    end
    else begin
      duty <= next_duty;
      leftDirection <= (isPowerPositive) ? `MOTOR_BACKWARD : `MOTOR_FORWARD;
      rightDirection <= (isPowerPositive) ? `MOTOR_BACKWARD : `MOTOR_FORWARD;
    end
  end

  // Use absolute value of motorPower to control the speed
  always @(*) begin
    if (absOfPower + MOTOR_PWM_OFFSET > 16'd1023)
      next_duty = 10'd1023;
    else
      // FIXME: 10 bits + 16 bits
      next_duty = absOfPower[9:0] + MOTOR_PWM_OFFSET;
  end


  // Debug
  assign debugDuty = duty;

endmodule

module motor_pwm (
  input clk,
  input reset,
  input [9:0] duty,
  output pmod_1 //PWM
);

  PWM_gen pwm_0 (
    .clk(clk),
    .reset(reset),
    .freq(32'd50000),
    .duty(duty),
    .PWM(pmod_1)
  );

endmodule

// generate PWM by input frequency & duty
module PWM_gen (
  input wire clk,
  input wire reset,
  input [31:0] freq,
  input [9:0] duty,
  output reg PWM
);
  wire [31:0] count_max = 100_000_000 / freq;
  wire [31:0] count_duty = count_max * duty / 1024;
  reg [31:0] count;

  always @(posedge clk, posedge reset) begin
    if (reset) begin
      count <= 0;
      PWM <= 0;
    end else if (count < count_max) begin
      count <= count + 1;
      if(count < count_duty)
        PWM <= 1;
      else
        PWM <= 0;
    end else begin
      count <= 0;
      PWM <= 0;
    end
  end
endmodule

