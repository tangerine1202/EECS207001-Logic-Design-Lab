`timescale 1ns/1ps

module And_4bits_in_nor_t;
reg [4-1:0] a = 4'b0;
wire out;

And_4bits_in_nor and_4bits_in_nor (
    .out(out),
    .a(a)
);

initial begin
    repeat (2 ** 4) begin
        #1 a = a + 1'b1;
    end
    #1 $finish;
end

endmodule