`timescale 1ns/1ps
`define CYC 4

module Mealy_Sequence_Detector_t ();

// IO port
reg clk = 1'b0;
reg rst_n = 1'b1;
reg in;
reg [4-1:0] seq = 4'b0000;
reg [2-1:0] i;
wire dec;


always #(`CYC/2) clk = ~clk;

Mealy_Sequence_Detector q1(
  .clk(clk),
  .rst_n(rst_n),
  .in(in),
  .dec(dec)
);

initial begin
  #`CYC  rst_n = 1'b0;
  #`CYC  rst_n = 1'b1;

  repeat (2 ** 4) begin
    i = 2'b11;
    in = seq[i];
    repeat (4) begin
      @ (posedge clk) begin
        if (i == 2'b0)
          Test;
      end
      @ (negedge clk) begin
        i = i - 2'b1;
        in = seq[i];
      end
    end
    seq = seq + 4'b1;
  end

  $finish;
end

task Test;
begin
  if (seq == 4'b1011 || seq == 4'b0011 || seq == 4'b1010) begin
    if (dec != 1'b1) begin
      $display("[ERROR], 'dec' should be 1");
      $write("seq: %b\n", seq);
      $write("dec: %d\n", dec);
      $display;
    end
  end
  else begin
    if (dec != 1'b0) begin
      $display("[ERROR], 'dec' should be 0");
      $write("seq: %b\n", seq);
      $write("dec: %d\n", dec);
      $display;
    end
  end
end
endtask

endmodule
