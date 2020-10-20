`timescale 1ns/1ps

`define CYC 4

module Memory_t ();

// # of words
parameter DEPTH = 128;
// # bits per words
parameter WIDTH = 8;

reg clk = 1'b1;
reg ren = 1'b0;
reg wen = 1'b0;
reg [7-1:0] addr = 7'b0;
reg [WIDTH-1:0] din = 8'b0;
wire [WIDTH-1:0] dout;

reg [WIDTH-1:0] out;
reg [DEPTH-1:0] mem [WIDTH-1:0];

integer idx = 0;
integer check_addr = 0;

Memory mem_0 (
  .clk(clk),
  .ren(ren),
  .wen(wen),
  .addr(addr),
  .din(din),
  .dout(dout)
);


always #(`CYC/2) clk = ~clk;

initial begin
  // Read before Write Test
  // test mem[0, 1]
  for (idx = 0; idx < 2; idx = idx+1) begin
    @ (negedge clk) begin
      GenerateTest(.read(1), .write(0), idx);
    end
    @ (posedge clk) begin
      // Test(.read(1), .write(0), idx);
      Test;
    end
  end
  // test mem[n-2, n-1]
  for (idx = DEPTH-1; idx > DEPTH-1-2; idx = idx-1) begin
    @ (negedge clk) begin
      GenerateTest(.read(1), .write(0), idx);
    end
    @ (posedge clk) begin
      // Test(.read(1), .write(0), idx);
      Test;
    end
  end


  // Read & Write at the same time Test (before Write)
  // test mem[0, 1]
  for (idx = 0; idx < 2; idx = idx+1) begin
    @ (negedge clk) begin
      GenerateTest(.read(1), .write(1), idx);
    end
    @ (posedge clk) begin
      // Test(.read(1), .write(0), idx);
      Test;
    end
  end
  // test mem[n-2, n-1]
  for (idx = DEPTH-1; idx > DEPTH-1-2; idx = idx-1) begin
    @ (negedge clk) begin
      GenerateTest(.read(1), .write(1), idx);
    end
    @ (posedge clk) begin
      // Test(.read(1), .write(0), idx);
      Test;
    end
  end


  // Read after Write Test
  // write mem[0, 7]
  for (idx = 0; idx < 8; idx = idx+1) begin
    @ (negedge clk) begin
      GenerateTest(.read(0), .write(1), idx);
    end
    @ (posedge clk) begin
      // Test(.read(1), .write(0), idx);
      Test;
    end
  end
  // write mem[n-1-8, n-1]
  for (idx = DEPTH-1; idx > DEPTH-1-8; idx = idx-1) begin
    @ (negedge clk) begin
      GenerateTest(.read(0), .write(1), idx);
    end
    @ (posedge clk) begin
      // Test(.read(1), .write(0), idx);
      Test;
    end
  end
  // read mem[0, 7]
  for (idx = 0; idx < 8; idx = idx+1) begin
    @ (negedge clk) begin
      GenerateTest(.read(1), .write(0), idx);
    end
    @ (posedge clk) begin
      // Test(.read(1), .write(0), idx);
      Test;
    end
  end
  // read mem[n-1-8, n-1]
  for (idx = DEPTH-1; idx > DEPTH-1-8; idx = idx-1) begin
    @ (negedge clk) begin
      GenerateTest(.read(1), .write(0), idx);
    end
    @ (posedge clk) begin
      // Test(.read(1), .write(0), idx);
      Test;
    end
  end


  // Read & Write at the same time Test (after Write)
  // test mem[0, 1]
  for (idx = 0; idx < 2; idx = idx+1) begin
    @ (negedge clk) begin
      GenerateTest(.read(1), .write(1), idx);
    end
    @ (posedge clk) begin
      Test;
    end
  end
  // test mem[n-2, n-1]
  for (idx = DEPTH-1; idx > DEPTH-1-2; idx = idx-1) begin
    @ (negedge clk) begin
      GenerateTest(.read(1), .write(1), idx);
    end
    @ (posedge clk) begin
      Test;
    end
  end


  // Stochastic Test
  repeat (2 ** 6) begin
    @ (negedge clk) begin
      GenerateTest(.read(0), .write(1), -1);
    end
    @ (posedge clk) begin
      Test;
    end
    @ (negedge clk) begin
      GenerateTest(.read(1), .write(0), -2);
    end
    @ (posedge clk) begin
      Test;
    end
  end

  $finish;
end


task Test;
  begin
    if (dout !== out) begin
      $display("[ERROR]");
      $write("ren: %d\n", ren);
      $write("wen: %d\n", wen);
      $write("din: %d\n", din);
      $write("addr: %d\n", addr);
      $write("dout: %d\n", dout);
      $write("out : %d\n", out);
      $display;
    end
  end
endtask


task GenerateTest;
  begin
    input read;
    input write;
    input idx;
    // generate
    ren = read;
    wen = write;
    din = $urandom_range(0, 256-1);
    if (idx === -1) begin
      addr = $uradmon_range(0, 128-1);
    end
    else if (idx === -2) begin
      addr = addr;
    end
    else begin
      addr = idx;
    end

    // udpate
    if (ren == 1'b1) begin
      out = mem[addr];
    end
    else if (wen == 1'b1) begin
      mem[addr] = din;
      out = 8'b0;
    end
    else begin
      out = 8'b0;
    end
  end
endtask

endmodule
