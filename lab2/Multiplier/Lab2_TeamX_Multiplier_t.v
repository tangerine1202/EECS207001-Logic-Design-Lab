`timescale 1ns/1ps

module Multiplier_t;

reg [4-1:0] a = 4'b0;
reg [4-1:0] b = 4'b0;
reg [8-1:0] p;

Multiplier mul (
    .a(a),
    .b(b),
    .p(p)
);

initial begin
    repeat (2 ** 4) begin
        #1 a = a + 1'b1; b = 1'b0;
        repeat (2 ** 4) begin
            #1 b = b + 1'b1;
        end
    end
    #1 $finish;
end


endmodule