// Modified from Lab6 - The Car

`define MOTOR_STOP 2'b00
`define MOTOR_FORWARD 2'b01   // [1]: backward, [0]: forward
`define MOTOR_BACKWARD 2'b10

module top (
  input clk,
  input rst,
  input [15:0] switch,
  output reg [3:0] in,         // IN4, IN3, IN2, IN1
  output [1:0] pwm,            // {left, right}
  output [3:0] led,
  output led15
);

assign led15 = switch[15];
assign led = in;

assign SPIN_TIME = 50_000;
reg [31:0] cnt;
reg [1:0] state;

assign pwm = 2'b11;

always @(posedge clk) begin
  if (cnt >= SPIN_TIME) begin
    cnt <= 32'd0;
    state <= state + 2'd1;
  end
  else begin
    cnt <= cnt + 32'd1;
    state <= state; 
  end
end

always @(*) begin
  if (switch[15] == 1'b0) begin
    case (state)
      2'd0: in = 4'b0101;
      2'd1: in = 4'b1001;
      2'd2: in = 4'b1010;
      2'd3: in = 4'b0110;
    endcase
  end
  else begin
    case (state)
      2'd0: in = 4'b0101;
      2'd1: in = 4'b0110;
      2'd2: in = 4'b1010;
      2'd3: in = 4'b1001;
    endcase
  end
end


endmodule

