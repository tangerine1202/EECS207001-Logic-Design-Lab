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
    enable_chk();
    bounce();
    out_boundary();
    max_min_out();
    random_change();

    $finish;
end

task random_change;
begin
    reset();
    #(`CYC * 2);
    max = $urandom_range(15);
    min = $urandom_range(15);
    #(`CYC * 10);
    max = $urandom_range(15);
    min = $urandom_range(15);
    #(`CYC * 10);
    max = $urandom_range(15);
    min = $urandom_range(15);
    #(`CYC * 10);
    max = $urandom_range(15);
    min = $urandom_range(15);
    #(`CYC * 10);
end
endtask

task max_min_out;
begin
    reset();
    // max == min
    #(`CYC * 4);
    max = 8;
    min = 8;
    #(`CYC * 2);
    max = 15;
    min = 0;

    // max == min == out
    #(`CYC * 4);
    max = 8;
    min = 8;
    #(`CYC *2);

    // reset max,min to 15,0
    max = 15;
    min = 0;
    #(`CYC * 4);
end
endtask

task out_boundary;
begin
    reset();
    // out of max boundary (max change)
    #(`CYC * 8) max = 5;
    #(`CYC * 2) max = 15;
    #(`CYC * 2);

    @ (negedge clk) flip = !flip;
    @ (negedge clk) flip = !flip;
    
    // out of min boundary (min change)
    #(`CYC * 4) min = 12;
    #(`CYC * 2);

    // reset max,min to 15,0
    max = 15;
    min = 0;
    #(`CYC * 4);
end
endtask

task bounce;
begin
    reset();
    #(`CYC * 36);
end
endtask

task enable_chk();
begin
    reset();
    #(`CYC * 4) enable = 1'b0;
    #(`CYC * 4) enable = 1'b1;
    #(`CYC * 4);
end
endtask

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