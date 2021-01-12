// Modified from Lab6 - The Car

`define MOTOR_STOP 2'b00
`define MOTOR_FORWARD 2'b01   // [1]: backward, [0]: forward
`define MOTOR_BACKWARD 2'b10

module top (
  input clk,
  input rst,
  output reg [1:0] direction,
  output pwm
);

parameter TURN_CONST = 32'd50_000_000;     // 100_000_000 / sec
reg [31:0] cnt;

always @(posedge clk) begin
  if (cnt >= TURN_CONST) begin
    cnt <= 32'd0;
    direction <= (direction == `MOTOR_FORWARD) ? `MOTOR_BACKWARD : `MOTOR_FORWARD;
  end
  else begin
    cnt <= cnt + 32'd1;
    direction <= direction;
  end
end

motor_pwm motor_pwm_0 (
  .clk(clk),
  .reset(rst),
  .duty(10'd1000),
  .pmod_1(pwm)
);

endmodule


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
    .freq(32'd25000),
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

