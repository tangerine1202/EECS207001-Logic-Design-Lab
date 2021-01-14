module top (
  input clk,
  input rst,
  // arduino
  input serialFromArduino,        // Serial signal from Arduino
  // motor
  output [1:0] leftDirection,     // Left  motor rotation direction
  output [1:0] rightDirection,    // Right motor rotation direction
  output leftSpeed,               // Left  motor pwm
  output rightSpeed,              // Right motor pwm
  // debug
  input switch,
  output [15:0] led,
  output [3:0] an,
  output [6:0] seg,
  output reg dp
);

// Parameters
parameter SIZE = 16;
parameter TARGET_ANGLE = 16'd180;
// parameter SAMPLE_TIME = 32'd1_662_500;   // Duration of angle sampling
// Due to different PID implementation approach, 'SAMPLE_TIME' is not used in the end.


// Wire & Reg
wire [SIZE-1:0] currAngle;       // Current angle received from Arduino
wire currAngleReady;             // If current angle is ready to be received
wire [SIZE-1:0] motorPower;      // Motor power used to control motor


// Receive angle from Arduino
Receive_From_Arduino rx_from_arduino (
  .clk(clk),
  .rst(rst),
  .serialFromArduino(serialFromArduino),
  .data(currAngle),
  .isDataReady(currAngleReady)
);

// Calculate motorPower by PID controller
PIDController #(
  .SIZE(SIZE),
  .TARGET_ANGLE(TARGET_ANGLE)
  // .SAMPLE_TIME(SAMPLE_TIME)
) pid_controller (
  .clk(clk),
  .rst(rst),
  .currAngleReady(currAngleReady),
  .currAngle(currAngle),
  .motorPower(motorPower)
);

// Turn motorPower into motor direction and pwm
Motor #(
  .SIZE(SIZE)
) motor (
  .clk(clk),
  .rst(rst),
  .motorPower(motorPower),
  .leftDirection(leftDirection),
  .rightDirection(rightDirection),
  .leftPwm(leftSpeed),
  .rightPwm(rightSpeed),
  // debug
  .debugDuty(debugDuty)
);


// Debug
reg [SIZE-1:0] debugLatestAngle;    // Latest angle
wire [9:0] debugDuty;               // Duty of the motor
reg [15:0] segNum;                  // Number to be displayed on 7-Segment
wire toggleSeg = switch;            // Toggle 7-Segment to display duty or latest angle

assign led[15] = leftSpeed;         // Display left motor pwm
assign led[14] = rightSpeed;        // Display right motor pwm
assign led[13:12] = leftDirection;  // Display left motor direction
assign led[11:10] = rightDirection; // Display right motor direction
assign led[9:0] = debugDuty[9:0];   // Display motor duty
assign dp = leftDirection[0];       // Display motor direction

// Toggle 7-Segment
assign segNum = (toggleSeg == 1'b0) ? {6'd0, debugDuty} : debugLatestAngle;

always @(posedge clk) begin
  if (currAngleReady == 1'b1) begin
    segNum <= currAngle;
    debugLatestAngle <= currAngle;
  end
  else begin
    segNum <= debugLatestAngle;
    debugLatestAngle <= debugLatestAngle;
  end
end

NumToSeg #(.SIZE(SIZE)) num2seg (
  .clk(clk),
  .num(segNum),
  .seg(seg),
  .an(an)
);

endmodule


module PIDController #(
  parameter SIZE = 16,
  parameter TARGET_ANGLE = 16'd180
  // parameter SAMPLE_TIME = 32'd1_662_500
) (
  input clk,
  input rst,
  input currAngleReady,
  input [SIZE-1:0] currAngle,
  output [SIZE-1:0] motorPower
);

// P, I, D parameters
parameter KP = 16'd77;
parameter KI = 16'd1;
parameter KD = 16'd10;

reg [SIZE-1:0] prevAngle;             // Previous angle
reg [SIZE-1:0] error;                 // Current error
reg [SIZE-1:0] errorSum;              // Integral of the error over time
reg [SIZE-1:0] errorDerivative;       // Estimate of the future error
wire [SIZE-1:0] next_error;
reg [SIZE-1:0] next_errorSum;
wire [SIZE-1:0] next_errorDerivative;
wire [SIZE-1:0] tmp_next_errorSum;

always @(posedge clk) begin
  if (rst == 1'b1) begin
    error <= 16'd0;
    errorSum <= 16'd0;
    errorDerivative <= 16'd0;
    prevAngle <= TARGET_ANGLE;
  end
  else begin
    if (currAngleReady == 1'b1) begin
      error <= next_error;
      errorSum <= next_errorSum;
      errorDerivative <= next_errorDerivative;
      prevAngle <= currAngle;
    end
    else begin
      error <= error;
      errorSum <= errorSum;
      errorDerivative <= errorDerivative;
      prevAngle <= prevAngle;
    end
  end
end


// Calculate next error
assign next_error = (currAngle - TARGET_ANGLE);

// Calculate next errorSum
/*
* Sample time is combined into KI parameter.
* Details are described in the report.
*/
assign tmp_next_errorSum = (errorSum + next_error);
always @(*) begin
  // Crop the 'errorSum' into the suit range
  if ((tmp_next_errorSum[SIZE-1] == 1'b0) && (tmp_next_errorSum > 16'd1023))
    next_errorSum = 16'd1023;
  else if ((tmp_next_errorSum[SIZE-1] == 1'b1) && (-tmp_next_errorSum > 16'd1023))
    next_errorSum = -16'd1023;
  else
    next_errorSum = tmp_next_errorSum;
end

// Calculate next errorDerivative
/*
* Sample time is combined into KD parameter.
* Since value of (currAngle - prevAngle) is about -360~360, if we divide it with
* sample time (about 1.6M), the result will always become 0.
* Details are described in the report.
*/
// assign next_errorDerivative = ((currAngle - prevAngle) / SAMPLE_TIME);
assign next_errorDerivative = (currAngle - prevAngle);


assign motorPower = ( KP * error
                    + KI * errorSum
                    + KD * errorDerivative );


endmodule