`timescale 1ns/1ps

module Memory_t ();

// # of words
parameter DEPTH = 128;
// # bits per words
parameter WIDTH = 8;
// cycle
parameter CYC = 4;

reg CLK = 1;

reg ren = 1'b0;
reg wen = 1'b0;
reg [7-1:0] addr = 7'b0;
reg [WIDTH-1:0] din = 8'b0;
wire [WIDTH-1:0] dout;

Memory mem_0 (
  .clk(CLK),
  .ren(ren),
  .wen(wen),
  .addr(addr),
  .din(din),
  .dout(dout)
);

always #(CYC/2) CLK = ~CLK;

initial begin
  repeat(2 ** 4) begin
    // @ (posedge CLK)
    @ (negedge CLK)
      Test;
  end
  $finish;
end

task Test;
begin
  ren = $urandom_range(0, 1);
  wen = $urandom_range(0, 1);
  addr = $urandom_range(0, 128-1);
  din = $urandom_range(0, 256-1);
end

endmodule
