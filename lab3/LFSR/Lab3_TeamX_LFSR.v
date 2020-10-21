`timescale 1ns/1ps

module LFSR (clk, rst_n, out);

input clk, rst_n;
output out;

wire d1_xor_d4;
reg [5-1:0] dff;

assign d1_xor_d4 = dff[1] ^ dff[4];

always @(posedge clk) begin
    if (rst_n == 0) begin
        dff <= 5'B11111;
    end
    else begin
        dff[4] <= dff[3];
        dff[3] <= dff[2];
        dff[2] <= dff[1];
        dff[1] <= dff[0];
        dff[0] <= d1_xor_d4;
    end
end

assign out = dff[4];

always @(dff) begin
    $display();
    $write("Dff: %5b,  d1d4: %b", dff, d1_xor_d4);
    $display();
end

endmodule
