`timescale 1ns/1ps

module FullAdder_1bit_in_nor_t;
reg a = 1'b0;
reg b = 1'b0;
reg cin = 1'b0;
wire sum;
wire cout;

FullAdder_1bit_in_nor fa_1bit_in_nor (
    .sum(sum),
    .cout(cout),
    .a(a),
    .b(b),
    .cin(cin)
);

initial begin 
    repeat (2 ** 2) begin
        #1 {a, b} = {a, b} + 1'b1;
        #1 cin = cin + 1'b1;
    end
end

endmodule