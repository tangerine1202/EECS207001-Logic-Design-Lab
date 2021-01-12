// Modified from Lab6 - The Car

`define MOTOR_STOP 2'b00
`define MOTOR_FORWARD 2'b01   // [1]: backward, [0]: forward
`define MOTOR_BACKWARD 2'b10

module top (
  input clk,
  input rst,
  input [10:0] switch,
  output reg [1:0] direction,
  output pwm,
  output [1:0] led
);

wire [9:0] duty;

assign led[0] = pwm;
assign led[1] = (direction == `MOTOR_FORWARD);
assign duty[9:0] = switch[9:0];

always @(posedge clk) begin
  direction <= (switch[10] == 1'b0) ? `MOTOR_BACKWARD : `MOTOR_FORWARD;
end

motor_pwm motor_pwm_0 (
  .clk(clk),
  .reset(rst),
  .duty(duty),
  .pmod_1(pwm)
);

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
    .freq(32'd05_000),
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

