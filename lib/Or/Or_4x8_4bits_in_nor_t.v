`timescale 1ns/1ps

module Or_4x8_4bits_in_nor_t;
reg [4-1:0] a0 = 4'b0;
reg [4-1:0] a1 = 4'b0;
reg [4-1:0] a2 = 4'b0;
reg [4-1:0] a3 = 4'b0;
reg [4-1:0] a4 = 4'b0;
reg [4-1:0] a5 = 4'b0;
reg [4-1:0] a6 = 4'b0;
reg [4-1:0] a7 = 4'b0;
wire [4-1:0] out;

Or_4x8_4bits_in_nor or_4x8_4bits_in_nor (
    .out(out),
    .a({a0, a1, a2, a3, a4, a5, a6, a7})
);

initial begin
    repeat (2 ** 8) begin
        #1 {a0, a1, a2, a3, a4, a5, a6, a7} = {a0, a2, a2, a3, a4, a5, a6, a7} + 1'b1;
        debug();
    end
    #1 $finish;
end

task debug;
begin
//    if (out !== a0|a1|a2|a3|a4|a5|a6|a7) begin
        $display("[Err]\n");
        $write("a0: %4b\n", a0);
        $write("a1: %4b\n", a1);
        $write("a2: %4b\n", a2);
        $write("a3: %4b\n", a3);
        $write("a4: %4b\n", a4);
        $write("a5: %4b\n", a5);
        $write("a6: %4b\n", a6);
        $write("a7: %4b\n", a7);
        $write("out: %4b\n", out);
        $write("exp: %4b\n", a0|a1|a2|a3|a4|a5|a6|a7);
        $display;
//    end
end
endtask

endmodule