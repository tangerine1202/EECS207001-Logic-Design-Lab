`timescale 1ns/1ps

`define CYC 4

module Parameterized_Ping_Pong_Counter_t ();
reg clk = 0;
reg rst_n = 1;
reg enable = 1;
reg flip = 0;
reg [4-1:0] max = 15, min = 0;
wire direction;
wire [4-1:0] out;

always #(`CYC/2) clk = ~clk;

Parameterized_Ping_Pong_Counter pppc (
    .clk(clk), 
    .rst_n(rst_n), 
    .enable(enable), 
    .flip(flip), 
    .max(max), 
    .min(min), 
    .direction(direction), 
    .out(out)
);

initial begin
    ta1();
    ta2();
    ta3();

    // TODO: max==min==output, hold value
    // TODO: change max, min while counting

    $finish;
end

task ta3;
begin
    reset();
    #(`CYC * 15);
    #(`CYC * 4);
end
endtask

task ta2;
begin
    reset();
    #(`CYC * 6);
    @ (negedge clk) flip = !flip;
    @ (negedge clk) flip = !flip;        
    #(`CYC * 4);
end
endtask

task ta1;
begin
    reset();
    #(`CYC * 6);
    repeat (2*4) begin
        @ (negedge clk) flip = !flip;        
    end
    #(`CYC * 4);
end
endtask

task reset;
begin
    @ (negedge clk)
    rst_n = 1'b0;
    @ (negedge clk)
    rst_n = 1'b1;
end
endtask

endmodule