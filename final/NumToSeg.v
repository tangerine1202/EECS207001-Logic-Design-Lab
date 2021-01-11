
module NumToSeg (clk, num, seg, an);

parameter SIZE = 16;
parameter DIV = 32'd100_000;

input clk;
input [SIZE-1:0] num;
output reg [6:0] seg; // cg~ca
output [3:0] an;

reg [3:0] digit;
reg [1:0] an_idx;
reg [32-1:0] cnt;
wire div_sig;

always @(posedge clk) begin
  if (cnt >= DIV - 32'b1)
    cnt <= 32'b0;
  else
    cnt <= cnt + 32'b1;
end
assign div_sig = (cnt == DIV - 32'b1) ? 1'b1: 1'b0;

always @(posedge clk) begin
  if (div_sig == 1'b1)
    an_idx <= an_idx + 2'b1;
  else
    an_idx <= an_idx;
end

assign an[3] = (an_idx == 2'd3) ? 1'b0 : 1'b1;
assign an[2] = (an_idx == 2'd2) ? 1'b0 : 1'b1;
assign an[1] = (an_idx == 2'd1) ? 1'b0 : 1'b1;
assign an[0] = (an_idx == 2'd0) ? 1'b0 : 1'b1;

always @(*) begin
  if (an_idx == 2'd0)
    digit = num % 32'd10;
  else if (an_idx == 2'd1)
    digit = num / 32'd10;
  else if (an_idx == 2'd2)
    digit = num / 32'd100;
  else if (an_idx == 2'd3)
    digit = num / 32'd1000;
  else
    digit = 4'd0;
end

always @(*) begin
  case (digit)
    4'd0: begin seg = 7'b1000000; end
    4'd1: begin seg = 7'b1111001; end
    4'd2: begin seg = 7'b0100100; end
    4'd3: begin seg = 7'b0110000; end
    4'd4: begin seg = 7'b0011001; end
    4'd5: begin seg = 7'b0010010; end
    4'd6: begin seg = 7'b0000010; end
    4'd7: begin seg = 7'b1111000; end
    4'd8: begin seg = 7'b0000000; end
    4'd9: begin seg = 7'b0010000; end
    // 4'ha: begin seg = 7'b0001000; end
    // 4'hb: begin seg = 7'b0000011; end
    // 4'hc: begin seg = 7'b1000110; end
    // 4'hd: begin seg = 7'b0100001; end
    // 4'he: begin seg = 7'b0000110; end
    // 4'hf: begin seg = 7'b0001110; end
    default: begin seg = 7'b1111111; end
  endcase
end

endmodule
