module top (
  input clk,
  input rst,                          // Reset
  input serialFromArduino,            // Serial signal from Arduino
  // motor
  output reg [1:0] leftDirection,     // IN[1], IN[0]
  output reg [1:0] rightDirection,    // IN[3], IN[2]
  output leftSpeed,
  output rightSpeed,
  // debug
  output [15:0] led,
  output [6:0] seg,
  output dp,
  output [3:0] an
);
// debug
wire [1:0] leftDirection;
wire [1:0] rightDirection;
wire leftSpeed;
wire rightSpeed;
wire [9:0] debug_duty;
wire [15:0] segNum;
assign leftDirection = direction;
assign rightDirection = direction;
// assign led[11:10] = rightDirection;
// assign led[13:12] = leftDirection;
assign led[14] = rightSpeed;
assign led[15] = leftSpeed;
assign led[13:10] = {leftDirection, rightDirection};
// assign led[15:0] = motorPower;
assign led[9:0] = debug_duty[9:0];
assign segNum = {6'd0, debug_duty};
assign dp = direction[0];



parameter SIZE = 16;

parameter TARGET_ANGLE = 16'd180;
// TODO: is this necessary? or count in PID controller?
// ANS: it's hard to calculate how many clk between arduino send data to ready to receive,
//      so realtime calculate in module seem to be a better solution.
 parameter CLKS_PER_DATA = 32'd1736;  // used in PID controller to calculate derivative term


wire [SIZE-1:0] currAngle;       // Current Angle (have been filtered)
wire currAngleReady;             // 'currAngle' is ready to be received
wire [SIZE-1:0] motorPower;      // Output of PID controller
wire [SIZE-1:0] absOfPower;      // Absolute value of 'motorPower'
wire isPowerPositive;            // Is 'motorPower' positive
wire [1:0] direction;            // Motor move direction


// Receive angle from Arduino
Receive_From_Arduino rx_from_arduino (
  .clk(clk),
  .rst(rst),
  .serialFromArduino(serialFromArduino),
  .data(currAngle),
  .isDataReady(currAngleReady)
);

PIDController #(
  .SIZE(SIZE),
  .TARGET_ANGLE(TARGET_ANGLE),
  .CLKS_PER_DATA(CLKS_PER_DATA)
) pid_controller (
  .clk(clk),
  .rst(rst),
  .currAngleReady(currAngleReady),
  .currAngle(currAngle),
  .motorPower(motorPower)
);

assign isPowerPositive = (motorPower[SIZE-1] == 1'b1) ? 1'd0 : 1'd1;
assign absOfPower = (isPowerPositive) ? motorPower : -motorPower;

Motor #(.SIZE(SIZE)) motor (
  .clk(clk),
  .rst(rst),
  .absOfPower(absOfPower),
  .isPowerPositive(isPowerPositive),
  .direction(direction),
  .pwm({leftSpeed, rightSpeed}),
  // debug
  .debug_duty(debug_duty)
);


NumToSeg #(.SIZE(SIZE)) num2seg (
  .clk(clk),
  .num(segNum),
  .seg(seg),
  .an(an)
);


endmodule


module PIDController #(
  parameter SIZE = 16,
  parameter TARGET_ANGLE = 16'd180,
  // FIXME: need to measure by manual (affect by gy521 sampling span, fpga-arduino communication span)
  parameter CLKS_PER_DATA = 16'd1736
) (
  input clk,
  input rst,
  input currAngleReady,
  input [SIZE-1:0] currAngle,
  output [SIZE-1:0] motorPower
);

// TODO: Need to be well tuned
parameter KP = 16'd2;
parameter KI = 16'd0;
parameter KD = 16'd0;

reg [SIZE-1:0] prevAngle;
reg [SIZE-1:0] error;
reg [SIZE-1:0] errorSum;
wire [SIZE-1:0] next_error;
reg [SIZE-1:0] next_errorSum;
wire [SIZE-1:0] tmp_next_errorSum;

always @(posedge clk) begin
  if (rst == 1'b1) begin
    error <= 16'd0;
    errorSum <= 16'd0;
    prevAngle <= TARGET_ANGLE;
  end
  else begin
    if (currAngleReady == 1'b1) begin
      error <= next_error;
      errorSum <= next_errorSum;
      prevAngle <= currAngle;
    end
    else begin
      error <= error;
      errorSum <= errorSum;
      prevAngle <= prevAngle;
    end
  end
end

assign next_error = (currAngle - TARGET_ANGLE);

assign tmp_next_errorSum = (errorSum + next_error);
always @(*) begin
  // crop the 'errorSum' to the suit range
  if ((tmp_next_errorSum[SIZE-1] == 1'b0)
      && (tmp_next_errorSum > 16'd1023))
    next_errorSum = 16'd1023;
  else if ((tmp_next_errorSum[SIZE-1] == 1'b1)
      && -tmp_next_errorSum > 16'd1023)
    next_errorSum = -16'd1023;
  else
    next_errorSum = tmp_next_errorSum;
end

// calculate output from P, I nd D values
assign motorPower = ( KP * (error)
                    + KI * (errorSum)
                    + KD * ((currAngle - prevAngle) / CLKS_PER_DATA) );


endmodule