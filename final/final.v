`timescale 1ns/1ps

module top (
);

parameter SIZE = 32;
// parameter TIME_CONST = ;

reg [SIZE-1:0] gyroAngle;   // Angle measured by gyroscope
reg [SIZE-1:0] acceAngle;   // Angle measured by accelerometer
reg [SIZE-1:0] currAngle;   // current Angle (have been filtered)

ComplementaryFilter #(.SIZE(SIZE)) complementary_filter (
    .gyroAngle(gyroAngle),
    .acceAngle(acceAngle),
    .currAngle(currAngle)
);

PIDController #(.SIZE(SIZE)) pid_controller (
    .clk(clk),
    .currAngle(currAngle),
    .motorPower(motorPower)
);



endmodule




module ComplementaryFilter (
    input [SIZE-1:0] gyroAngle,
    input [SIZE-1:0] acceAngle,
    output [SIZE-1:0] currAngle
);

parameter SIZE= 32;  
// ref: Arudino Self-Balancing Robot to tune the value
// FIXME: is float nubmer allowed in FPGA ???
parameter GYRO_RATIO= 0.9;

assign currAngle = (GYRO_RATIO * (prevAngle - gyroAngle)) + (32'd1 - GYRO_RATI* (acceAngle));
                   
endmodule




module PIDController (
    input clk;
    input [SIZE-1:0] currAngle,
    output [SIZE-1:0] motorPower
);

parameter SAMPLE_TIME = ;
parameter TARGET_ANGLE = 0;
// TODO: need to be well tuned
// FIXME: is float nubmer allowed in FPGA ???
parameter KP = 1;
parameter KI = 0;
parameter KD = 0;

reg [SIZE-1:0] prevAngle;
reg [SIZE-1:0] error;
reg [SIZE-1:0] errorSum;
reg [SIZE-1:0] next_error;
reg [SIZE-1:0] next_errorSum;

assign next_error = currAngle - TARGET_ANGLE;
// TODO: crop the 'errorSum' to suit range?
// FIXME: use 'error' or 'next_error'?
assign next_errorSum = errorSum + error;   


always @(posedge clk) begin
    if (SAMPLE_TIME) begin
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

// calculate output from P, I nd D values
assign motorPower = ( KP * (error) 
                    + KI * (errorSum)
                    + KD * ((currAngle - prevAngle) / SAMPLE_TIME) );


endmodule