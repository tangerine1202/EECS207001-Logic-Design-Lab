`timescale 1ns/1ps

`define CYC 4

module Sliding_Window_Detector_t ();

reg clk = 1'b1;
reg rst_n = 1'b1;
reg in = 1'b0;
wire dec1;
wire dec2;

Sliding_Window_Detector SWD (
    .clk(clk),
    .rst_n(rst_n),
    .in(in),
    .dec1(dec1),
    .dec2(dec2)
);

always #(`CYC/2) clk = ~clk;

initial begin
    reset;


end

// testcase on lab5 pdf
task dec1_pdf;
begin
    Zero;
    One;
    Zero;
    One;  // dec1 = 1'b1
    Zero;
    One;  // dec1 = 1'b1

    One;
    One;  // STOP state
    One;
    One;

    Zero;
    One;
    Zero;
    One;
    Zero;
    One;
end
endtask

task dec2_pdf;
begin
    Zero;
    One;
    Zero;
    Zero;
    Zero;

    One;
    One;
    Zero;
    One;  // dec2 = 1'b1
    One;
    Zero;
    One;  // dec2 = 1'b1
    One;
    Zero;
    One;  // dec2 = 1'b1

    One;
end
endtask

task check;
begin
    
end
endtask

// reset signal
task reset;
begin
    @(negedge clk) rst_n = 1'b0;
    @(negedge clk) rst_n = 1'b1;
end
endtask

// in = 1'b0 signal
task Zero;
begin
    @(negedge clk) in = 1'b0;
end
endtask

// in = 1'b1 signal
task One;
begin
    @(negedge clk) in = 1'b1;
end
endtask

endmodule