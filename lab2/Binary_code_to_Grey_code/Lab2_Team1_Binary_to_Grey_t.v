`timescale 1ns/1ps

module Binary_to_Grey_t;

parameter SIZE = 4;

reg [SIZE-1:0] din = 4'b0;
wire [SIZE-1:0] dout;

Binary_to_Grey binary_to_gray (
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
