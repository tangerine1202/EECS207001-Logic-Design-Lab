module motor(
  input clk,
  input rst,
  // input [??:0] mode,
  output [1:0] pwm  // {left, right}
);

  parameter NORMAL_FORWARD = 10'd512;

  reg [9:0]next_left_duty, next_right_duty;
  reg [9:0]left_duty, right_duty;
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

  assign pwm = {left_pwm, right_pwm};

  always@(posedge clk)begin
    if(rst)begin
      left_duty <= 10'd0;
      right_duty <= 10'd0;
    end else begin
      left_duty <= next_left_duty;
      right_duty <= next_right_duty;
    end
  end

  // TODO: take the right speed for different situation
  always @(*) begin
    //case (mode)
      //default: begin
        next_left_duty = NORMAL_FORWARD;
        next_right_duty = NORMAL_FORWARD;
      //end
    // endcase
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
    .freq(32'd25000),
    .duty(duty),
    .PWM(pmod_1)
  );

endmodule

//generate PWM by input frequency & duty
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

