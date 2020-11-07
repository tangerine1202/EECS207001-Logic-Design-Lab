`timescale 1ns/1ps

module Mealy_Sequence_Detector (clk, rst_n, in, dec);

parameter S0 = 4'h0;  // Intial state
parameter S1 = 4'h1;  
parameter S2 = 4'h2;  
parameter S3 = 4'h3;  
parameter S5 = 4'h5;  
parameter S6 = 4'h6; 
parameter S7 = 4'h7;
parameter F0 = 4'ha;
parameter F1 = 4'hb;

input clk, rst_n;
input in;
output reg dec;

reg [4-1:0] state;
reg [4-1:0] next_state;


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
      next_state = (in) ? S1 : S5;
      dec = (in) ? 1'b0 : 1'b0;
    end
    S1: begin
      next_state = (in) ? F0 : S2;
      dec = (in) ? 1'b0 : 1'b0;
    end
    S2: begin
      next_state = (in) ? S3 : F1;
      dec = (in) ? 1'b0 : 1'b0;
    end
    S3: begin
      next_state = (in) ? S0 : S0;
      dec = (in) ? 1'b1 : 1'b1;
    end
    S5: begin
      next_state = (in) ? F0 : S6;
      dec = (in) ? 1'b0 : 1'b0;
    end
    S6: begin
      next_state = (in) ? S7 : F1;
      dec = (in) ? 1'b0 : 1'b0;
    end
    S7: begin
      next_state = (in) ? S0 : S0;
      dec = (in) ? 1'b1 : 1'b0;
    end
    F0: begin
      next_state = (in) ? F1 : F1;
      dec = (in) ? 1'b0 : 1'b0;
    end
    F1: begin
      next_state = (in) ? S0 : S0;
      dec = (in) ? 1'b0 : 1'b0;
    end
    default: begin
      next_state = (in) ? S0 : S0;
      dec = (in) ? 1'b0 : 1'b0;
    end
  endcase
end

endmodule
