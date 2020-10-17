`timescale 1ns/1ps

module Multiplier_t;

reg [4-1:0] a = 4'b0;
reg [4-1:0] b = 4'b0;
wire [8-1:0] p;

Multiplier mul (
    .a(a),
    .b(b),
    .p(p)
);

initial begin
    repeat (2 ** 4) begin
        #1 a = a + 1'b1; b = 1'b0;
        debug();
        repeat (2 ** 4) begin
            #1 b = b + 1'b1;
            debug();
        end
    end
    #1 $finish;
end

task debug;
reg [8-1:0] mul;
begin
    if(p != mul) begin
        $display("[-]");
        $write("a: %d\n", a);
        $write("b: %d\n", b);
        $write("current p: %d\n", p);
        $write("desired p: %d\n", mul);
        $display;
    end
    mul = a*b;
end
endtask

endmodule