`timescale 1ns/1ps

module Decoder_t;

parameter SIZE_IN = 4;
parameter SIZE_OUT = 16;

reg [SIZE_IN-1:0] din = 4'b0;
wire [SIZE_OUT-1:0] dout;

Decoder decoder_0 (
  .din(din),
  .dout(dout)
);

initial begin
  repeat (2 ** 4) begin
    #1 din = din + 4'b1;
  end
  #1 $finish;
end


endmodule
