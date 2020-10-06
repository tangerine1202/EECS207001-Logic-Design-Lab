`timescale 1ns/1ps

module FullAdder_4bits_in_nor_t;
parameter SIZE = 4;
reg [SIZE-1:0] a = 4'b0;
reg [SIZE-1:0] b = 4'b0;
reg [0:0 ]cin = 1'b0;
wire [SIZE-1:0] sum;
wire cout;

FullAdder_4bits_in_nor fa_4bits_in_nor (
    .sum(sum),
    .cout(cout),
    .a(a),
    .b(b),
    .cin(cin)
);

initial begin 
    repeat (2 ** 4) begin
        #1 a = a + 1'b1; b = 4'b0;
        repeat (2 ** 4) begin
            #1 b = b + 1'b1;
            #1 cin = cin + 1'b1;
        end
    end
end

endmodule