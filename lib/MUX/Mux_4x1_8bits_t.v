// FIXME: untested, may un-runable or act incorrect.
`timescale 1ns/1ps

module Mux_4x1_8bits_t ();

parameter SIZE_SEL = 2;
parameter SIZE_M = 4;
parameter SIZE_N = 8;

reg [SIZE_N-1:0] in [SIZE_M-1:0];  // an <SIZE_N>-bit vector with a depth of <SIZE_M>
reg [SIZE_SEL-1:0] sel = 2'b0;
wire [SIZE_N-1:0] out;

// utils
integer i;
reg [SIZE_N-1:0] counter;

Mux_4x1_8bits mux_4x1_8bits (
  .in(in),
  .sel(sel),
  .out(out)
);


initial begin
  initialize();
  #1
  repeat(SIZE_M) begin
    #1 sel = sel + 2'b1;
  end
  #1 $finish;
end


task initialize;
  $display("init start");
  counter = 4'b0;
  for(i=0; i<SIZE_M; i=i+1) begin
    in[i] = counter;
    counter = counter + 4'b1;
    $display("in[%0d] = %0d", i, counter);
  end
  $display("init end");
endtask

endmodule