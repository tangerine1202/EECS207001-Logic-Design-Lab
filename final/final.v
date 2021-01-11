`timescale 1ns/1ps

module top (
  input rst,                          // Reset
  input serialFromArduino,            // Serial signal from Arduino
  // motor
  // output reg [1:0] leftDirection,
  // output reg [1:0] rightDirection,
  // output leftSpeed,
  // output rightSpeed,
  // debug
  output [5:0] led,
  output reg [6:0] seg,
  output dp,
  output [3:0] an
);
// debug
reg [1:0] leftDirection;
reg [1:0] rightDirection;
wire leftSpeed;
wire rightSpeed;
assign led[0] = rightSpeed;
assign led[2:1] = rightDirection;
assign led[4:3] = leftDirection;
assign led[5] = leftSpeed;



parameter SIZE = 16;

parameter TARGET_ANGLE = 16'd180;
// TODO: is this necessary? or count in PID controller?
// parameter CLKS_PER_DATA = 32'd1736;  // used in PID controller to calculate derivative term


// reg [SIZE-1:0] gyroAngle,     // Angle measured by gyroscope
// reg [SIZE-1:0] acceAngle,     // Angle measured by accelerometer
reg [SIZE-1:0] currAngle,         // Current Angle (have been filtered)
reg currAngleReady;                    // 'currAngle' is ready to be received
reg [SIZE-1:0] motorPower;              // Output of PID controller
reg [SIZE-1:0] absOfPower;              // Absolute value of 'motorPower'
reg isPowerPositive;                    // Is 'motorPower' positive


// Receive angle from Arduino
Receive_From_Arduino rx_from_arduino (
  .clk(clk),
  .rst(rst),
  .serialFromArduino(serialFromArduino),
  .data(currAngle),
  .isDataReady(currAngleReady)
);


// TODO: skip filter for test
// ComplementaryFilter #(.SIZE(SIZE)) complementary_filter (
  // .gyroAngle(gyroAngle),
  // .acceAngle(acceAngle),
  // .currAngle(currAngle)
// );

PIDController #(
  .SIZE(SIZE),
  .TARGET_ANGLE(TARGET_ANGLE),
  .CLKS_PER_DATA(CLKS_PER_DATA)
) pid_controller (
  .clk(clk),
  .currAngleReady(currAngleReady),
  .currAngle(currAngle),
  .motorPower(motorPower)
);

assign isPowerPositive = (motorPower > 16'd0) ? 1'd1 : 1'd0;
assign absOfPower = (isPowerPositive) ? motorPower : -motorPower;

Motor #(.SIZE(SIZE)) motor (
  .clk(clk),
  .rst(rst),
  .absOfPower(absOfPower),
  .isPowerPositive(isPowerPositive),
  .direction({leftDirection, rightDirection}),
  .pwm({leftSpeed, rightSpeed})
);


NumToSeg num2seg (
  .clk(clk),
  .num(absOfPower),
  .seg(seg),
  .an(an)
);
assign dp = isPowerPositive;


endmodule



/*
module ComplementaryFilter (
  input [SIZE-1:0] gyroAngle,
  input [SIZE-1:0] acceAngle,
  output [SIZE-1:0] currAngle
);

parameter SIZE= 16;
// ref: Arduino Self-Balancing Robot to tune the value
// FIXME: float number is not synthesizable
parameter GYRO_RATIO= 0.9;

assign currAngle = (GYRO_RATIO * (prevAngle - gyroAngle)) + (32'd1 - GYRO_RATE* (acceAngle));

endmodule
*/




module PIDController (
  input clk,
  input currAngleReady,
  input [SIZE-1:0] currAngle,
  output [SIZE-1:0] motorPower
);

parameter SIZE = 16;
parameter TARGET_ANGLE = 16'd180;
// FIXME: need to measure by manual (affect by gy521 sampling span, fpga-arduino communication span)
parameter CLKS_PER_DATA = 16'd1736;

// TODO: Need to be well tuned
parameter KP = 1;
parameter KI = 0;
parameter KD = 0;

reg [SIZE-1:0] prevAngle;
reg [SIZE-1:0] error;
reg [SIZE-1:0] errorSum;
reg [SIZE-1:0] next_error;
reg [SIZE-1:0] next_errorSum;
reg [SIZE-1:0] tmp_next_errorSum;

always @(posedge clk) begin
  if (currAngleReady) begin
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

assign next_error = currAngle - TARGET_ANGLE;

assign tmp_next_errorSum = errorSum + error;
always @(*) begin
  // crop the 'errorSum' to the suit range
  if (tmp_next_errorSum > 16'd300)
    next_errorSum = 16'd300;
  else if (tmp_next_errorSum < -16'd300)
    next_errorSum = -16'd300;
  else
    next_errorSum = tmp_next_errorSum;
end

// calculate output from P, I nd D values
assign motorPower = ( KP * (error)
                    + KI * (errorSum)
                    + KD * ((currAngle - prevAngle) / CLKS_PER_DATA) );


endmodule