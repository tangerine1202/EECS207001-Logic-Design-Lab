`timescale 1ns/1ps

module Decoder_3x8_t;

parameter SIZE_IN = 3;
parameter SIZE_OUT = 8;

reg [SIZE_IN-1:0] sel = 3'b0;
wire [SIZE_OUT-1:0] out;

Decoder_3x8 decoder_3x8 (
  .sel(sel),
  .out(out)
);

initial begin
  repeat (2 ** 3) begin
    #1 sel = sel + 3'b1;
  end
  #1 $finish;
end

endmodule