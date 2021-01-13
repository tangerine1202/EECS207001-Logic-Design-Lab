// Modified from Lab6 - The Car

`define MOTOR_STOP 2'b00
`define MOTOR_FORWARD 2'b01   // [1]: backward, [0]: forward
`define MOTOR_BACKWARD 2'b10

module Motor #(
    parameter SIZE = 16,
    parameter  MOTOR_PWM_OFFSET = 16'd400
) (
  input clk,
  input rst,
  input [SIZE-1:0] motorPower,
  output reg [1:0] direction,
  output [1:0] pwm,              // {left, right}
  // debug
  output [9:0] debug_duty
);
  // debug
  assign debug_duty = duty;

  wire [SIZE-1:0] absOfPower;
  wire isPowerPositive;
  reg [9:0] duty;
  reg [9:0] next_duty;
  wire [9:0] left_duty, right_duty;
  // reg [9:0] next_left_duty, next_right_duty;
  wire left_pwm, right_pwm;

  motor_pwm m0(
    .clk(clk),
    .reset(rst),
    .duty(left_duty),
    .pmod_1(left_pwm)
  );
  motor_pwm m1(
    .clk(clk),
    .reset(rst),
    .duty(right_duty),
    .pmod_1(right_pwm)
  );

  assign isPowerPositive = (motorPower[SIZE-1] == 1'b1) ? 1'd0 : 1'd1;
  assign absOfPower = (isPowerPositive) ? motorPower : -motorPower;

  assign pwm = {left_pwm, right_pwm};

  assign left_duty = duty;
  assign right_duty = duty;
  

  always @(posedge clk) begin
    if (rst == 1'b1) begin
      duty <= 10'd0;
      direction <= `MOTOR_STOP;
      // left_duty <= 10'd0;
      // right_duty <= 10'd0;
    end 
    else begin
      duty <= next_duty;
      direction <= (isPowerPositive) ? `MOTOR_BACKWARD : `MOTOR_FORWARD;
      // left_duty <= next_left_duty;
      // right_duty <= next_right_duty;
    end
  end

  always @(*) begin
    // 'duty' range -> 0~1023
    if (absOfPower + MOTOR_PWM_OFFSET > 16'd1023)
      next_duty = 10'd1023;
    else
      next_duty = absOfPower[9:0] + MOTOR_PWM_OFFSET;
  end

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
    // FIXME: higher freq since cause to lower response for motor
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

