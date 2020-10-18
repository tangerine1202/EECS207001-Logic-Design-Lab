`timescale 1ns/1ps

module LFSR (clk, rst_n, out);
input clk, rst_n;
output out;

reg d1_xor_d4;
reg [5-1:0] dff;

always @(posedge clk or negedge rst_n) begin
    if (rst_n == 0) begin
        dff <= 5'b11111;
    end
    else begin
        d1_xor_d4 <= dff[1] ^ dff[4];
        dff[4] <= dff[3];
        dff[3] <= dff[2];
        dff[2] <= dff[1];
        dff[1] <= dff[0];
        dff[0] <= d1_xor_d4;
    end
end

assign out = dff[4];

endmodule
