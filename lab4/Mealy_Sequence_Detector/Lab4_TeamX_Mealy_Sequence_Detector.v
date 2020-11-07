`timescale 1ns/1ps

module Mealy_Sequence_Detector (clk, rst_n, in, dec);

parameter S0 = 3'b000;  // Intial state
parameter S1 = 3'b001;  // 1st input match state
parameter S2 = 3'b010;  // 2nd input match state
parameter S3 = 3'b011;  // 3nd input match state
parameter S4 = 3'b100;  // 4nd input match state
parameter F0 = 3'b111;  // S1 failed to match next pattern
parameter F1 = 3'b110;  // S2 failed to match next pattern

input clk, rst_n;
input in;
output reg dec;

reg [3-1:0] state;
reg [3-1:0] next_state;


// SC: state transition
always @(posedge clk) begin
  if (rst_n == 1'b0) begin
    state <= S0;
  end
  else begin
    state <= next_state;
  end
end


// CC: next state & dec (output)
always @(*) begin
  case (state)
    S0: begin
      next_state = (in == 1'b0) ? S1 : S1;
      dec = (in == 1'b0) ? 1'b0 : 1'b0;
    end
    S1: begin
      next_state = (in == 1'b0) ? F0 : S2;
      dec = (in == 1'b0) ? 1'b0 : 1'b0;
    end
    S2: begin
      next_state = (in == 1'b0) ? S3 : F1;
      dec = (in == 1'b0) ? 1'b0 : 1'b0;
    end
    S3: begin
      next_state = (in == 1'b0) ? S4 : S4;
      dec = (in == 1'b0) ? 1'b1 : 1'b1;
    end
    S4: begin
      next_state = (in == 1'b0) ? S0 : S0;
      dec = (in == 1'b0) ? 1'b0 : 1'b0;
    end
    F0: begin
      next_state = (in == 1'b0) ? F1 : F1;
      dec = (in == 1'b0) ? 1'b0 : 1'b0;
    end
    F1: begin
      next_state = (in == 1'b0) ? S4 : S4;
      dec = (in == 1'b0) ? 1'b0 : 1'b0;
    end
    default: begin
      next_state = (in == 1'b0) ? S0 : S0;
      dec = (in == 1'b0) ? 1'b0 : 1'b0;
    end
  endcase
end

endmodule
