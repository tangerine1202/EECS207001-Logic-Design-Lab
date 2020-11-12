`timescale 100ps/1ps

`define CYC 4

module Greatest_Common_Divisor_t ();

reg clk = 1'b1;
reg rst_n = 1'b1;
reg Begin = 1'b0;
reg [16-1:0] a = 16'h0;
reg [16-1:0] b = 16'h0;
wire Complete;
wire [16-1:0] gcd;
integer i, j, k;

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
  reset;
  
  // a = 0
  test(0, 12);
  test(0, 3);
  test(0, 100);

  // b = 0
  test(34, 0);
  test(67, 0);
  test(281, 0);
  
  // prime
  test(60013, 60101);
  test(60091, 60077);
  test(60041, 60083);

  // small number
  for(i = 1 ; i <= 100 ; i=i+1) begin
    for(j = 1 ; j <= 100 ; j=j+1) begin
      test(i, j);
    end
  end
  // large number
  for(i = 32'hffff ; i >= 32'hffff-10 ; i=i-1) begin
    for(j = 32'hffff ; j >= 32'hffff-10 ; j=j-1) begin
      test(i, j);
    end
  end

  // random test
  for(k = 0 ; k < 10000 ; k=k+1) begin
    i = $urandom_range(1, 32'hffff);
    j = $urandom_range(1, 32'hffff);
    test(i, j);
    test(j, i);
  end
  
  $finish;
end

task reset;
begin
  @(negedge clk) rst_n = 1'b0;
  @(negedge clk) rst_n = 1'b1;
end
endtask

task test(input integer x, input integer y);
begin
  @(negedge clk)
    a = x;
    b = y;
    Begin = 1'b1;
  @(negedge clk)
    Begin = 1'b0;
  @(posedge Complete) begin
    check_gcd;
    check_complete;
  end
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
  @(negedge clk) if(Complete != 1'b1) begin
    $display("[Error] Complete signal down too early (a=%d, b=%d)", a, b);
  end
  @(posedge clk) if(Complete != 1'b1) begin
    $display("[Error] Complete signal down too early (a=%d, b=%d)", a, b);
  end
  @(negedge clk) if(Complete != 1'b1) begin
    $display("[Error] Complete signal down too early (a=%d, b=%d)", a, b);
  end
end
endtask

endmodule