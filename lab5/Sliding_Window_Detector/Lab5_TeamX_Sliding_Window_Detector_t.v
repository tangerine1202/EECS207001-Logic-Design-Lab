`timescale 1ns/1ps

`define CYC 4

module Sliding_Window_Detector_t ();

reg clk = 1'b1;
reg rst_n = 1'b1;
reg in = 1'b0;
wire dec1;
wire dec2;

reg [3-1:0] chk1_in;
reg [4-1:0] chk2_in;
reg chk1_stop;

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
    
    dec1_pdf;
    #(`CYC*2);
    dec2_pdf;

    $finish;
end

always @(in) begin
    // Dec1 check
    chk1_in[2:1] = chk1_in[1:0]
    chk1_in[0]   = in;
    if (chk1_in == 3'b111)
        chk1_stop = 1'b1;
    else
        chk1_stop = 1'b0;
    if (chk1_stop == 1'b0) begin
        if (chk1_in == 3'b101) begin
            check_1(1'b1);
        end
        else begin
            check_1(1'b0);
        end
    end
    else begin
        check_1(1'b0);
    end


    // Dec2 check
    chk2_in[3:1] = chk2_in[2:0];
    chk2_in[0]   = in;
    if (chk2_in == 4'b1101) begin
        check_2(1'b1);
    end
    else begin
        check_2(1'b0);
    end
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

task check_1(input expect);
begin
    if (dec1 != expect) begin
        $timeformat(-9, 2, " ns", 20);  // specify %t format
        $display("[-] %t: Dec1 expect %b, but get %b.", $time, expect, dec1);
    end
end
endtask

task check_2(input expect);
begin
    if (dec2 != expect) begin
        $timeformat(-9, 2, " ns", 20);  // specify %t format
        $display("[-] %t: Dec2 expect %b, but get %b.", $time, expect, dec2);
    end
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