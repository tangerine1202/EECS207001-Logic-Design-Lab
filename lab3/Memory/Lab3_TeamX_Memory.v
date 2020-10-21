`timescale 1ns/1ps

module Memory (clk, ren, wen, addr, din, dout);

// # of words
parameter DEPTH = 128;
// # bits per words
parameter WIDTH = 8;

input clk;
input ren;
input wen;
input [7-1:0] addr;
input [8-1:0] din;
output reg [8-1:0] dout;

reg [WIDTH-1:0] mem [DEPTH-1:0];

always @(posedge clk) begin
    if (ren == 1'b1) begin
      // Read 'mem' to 'out'
      // mem[addr] <= mem[addr];
      dout <= mem[addr];
    end
    else begin
      if (wen == 1'b1) begin
        // Write 'din' to 'mem'
        mem[addr] <= din;
        dout <= 8'b0;
      end
      else begin
        // Do nothing
        // mem <= mem;
        dout <= 8'b0;
      end
    end
end

endmodule
