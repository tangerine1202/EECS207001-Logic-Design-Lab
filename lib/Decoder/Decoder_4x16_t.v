`timescale 1ns/1ps

module Decoder_4x16_t;

parameter SIZE_IN = 4;
parameter SIZE_OUT = 16;

reg [SIZE_IN-1:0] sel = 4'b0;
wire [SIZE_OUT-1:0] out;

Decoder_n_4x16_in_nand decoder_4x16 (
  .sel(sel),
  .out(out)
);

initial begin
  repeat (2 ** 4) begin
    #1 sel = sel + 4'b1;
  end
  #1 $finish;
end

endmodule