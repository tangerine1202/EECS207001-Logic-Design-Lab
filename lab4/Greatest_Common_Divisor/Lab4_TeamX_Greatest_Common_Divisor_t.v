`timescale 1ns/1ps

`define CYC 4

module Greatest_Common_Divisor_t();

reg clk = 1'b1;
reg rst_n = 1'b1;
reg Begin = 1'b0;
reg [16-1:0] a = 16'h0;
reg [16-1:0] b = 16'h0;
wire Complete;
wire [16-1:0] gcd;
integer i, j;

Greatest_Common_Divisor gcd0 (
    .clk(clk),
    .rst_n(rst_n),
    .Begin(Begin),
    .a(a),
    .b(b),
    .Complete(Complete),
    .gcd(gcd)
);

always #(`CYC/2) clk = ~clk;

initial begin
    reset();
    for(i = 0 ; i < 100 ; i=i+1) begin
        #(`CYC) a = i;
        for(j = 0 ; j < 100 ; j=j+1) begin
            b = j;
            @(negedge clk) Begin = 1'b1;
            @(negedge clk) Begin = 1'b0;
            @(posedge Complete) begin
                check_gcd();
                // check_complete();
            end
        end
    end
end

task reset;
begin
    @(negedge clk) rst_n = 1'b0;
    @(negedge clk) rst_n = 1'b1;
end
endtask

task check_gcd;
reg [16-1:0] aa, bb;
begin
    aa = a;
    bb = b;
    if(aa == 16'h0) begin 
        if (bb != gcd) begin
            $display("[Error] a=%d, b=%d", a, b);
            $display("  gcd=%d, expected_gcd=%d", gcd, bb);
        end
    end
    while (bb != 0) begin
        if (aa > bb) aa = aa % bb;
        else         bb = bb % aa;
    end
    if (bb == 16'h0) begin
        if (aa != gcd) begin
            $display("[Error] a=%d, b=%d", a, b);
            $display("  gcd=%d, expected_gcd=%d", gcd, aa);
        end
    end
end
endtask

task check_complete;
begin
    @(posedge clk) if(Complete != 1'b1) begin
        $display("[Error] Complete signal down too early (a=%d, b=%d)", a, b);
    end
    @(negedge clk) if(Complete != 1'b1) begin
        $display("[Error] Complete signal down too early (a=%d, b=%d)", a, b);
    end
    @(posedge clk) if(Complete != 1'b1) begin
        $display("[Error] Complete signal down too early (a=%d, b=%d)", a, b);
    end
end
endtask

endmodule