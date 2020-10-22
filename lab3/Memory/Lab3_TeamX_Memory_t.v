`timescale 1ns/1ps

`define CYC 4

module Memory_t ();

// # of words
parameter DEPTH = 128;
// # bits per words
parameter WIDTH = 8;
// addr_source: from input or from random
parameter USE_INPUT_ADDR = 1'b0;
parameter USE_RANDOM_ADDR = 1'b1;

reg clk = 1'b1;
reg ren = 1'b0;
reg wen = 1'b0;
reg [7-1:0] addr = 7'b0;
reg [WIDTH-1:0] din = 8'b0;
wire [WIDTH-1:0] dout;

reg [WIDTH-1:0] out;
reg [WIDTH-1:0] mem [DEPTH-1:0];

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
      GenerateTest(.read(1), .write(0), .addr_input(idx), .addr_source(USE_INPUT_ADDR));
    end
    @ (posedge clk) begin
      Test;
    end
  end
  // test mem[n-2, n-1]
  for (idx = DEPTH-1; idx > DEPTH-1-2; idx = idx-1) begin
    @ (negedge clk) begin
      GenerateTest(.read(1), .write(0), .addr_input(idx), .addr_source(USE_INPUT_ADDR));
    end
    @ (posedge clk) begin
      Test;
    end
  end


  // Read & Write at the same time Test (before Write)
  // test mem[0, 1]
  for (idx = 0; idx < 2; idx = idx+1) begin
    @ (negedge clk) begin
      GenerateTest(.read(1), .write(1), .addr_input(idx), .addr_source(USE_INPUT_ADDR));
    end
    @ (posedge clk) begin
      Test;
    end
  end
  // test mem[n-2, n-1]
  for (idx = DEPTH-1; idx > DEPTH-1-2; idx = idx-1) begin
    @ (negedge clk) begin
      GenerateTest(.read(1), .write(1), .addr_input(idx), .addr_source(USE_INPUT_ADDR));
    end
    @ (posedge clk) begin
      Test;
    end
  end


  // Read after Write Test
  // write mem[0, 7]
  for (idx = 0; idx < 8; idx = idx+1) begin
    @ (negedge clk) begin
      GenerateTest(.read(0), .write(1), .addr_input(idx), .addr_source(USE_INPUT_ADDR));
    end
    @ (posedge clk) begin
      Test;
    end
  end
  // write mem[n-1-8, n-1]
  for (idx = DEPTH-1; idx > DEPTH-1-8; idx = idx-1) begin
    @ (negedge clk) begin
      GenerateTest(.read(0), .write(1), .addr_input(idx), .addr_source(USE_INPUT_ADDR));
    end
    @ (posedge clk) begin
      Test;
    end
  end
  // read mem[0, 7]
  for (idx = 0; idx < 8; idx = idx+1) begin
    @ (negedge clk) begin
      GenerateTest(.read(1), .write(0), .addr_input(idx), .addr_source(USE_INPUT_ADDR));
    end
    @ (posedge clk) begin
      // Test(.read(1), .write(0), idx);
      Test;
    end
  end
  // read mem[n-1-8, n-1]
  for (idx = DEPTH-1; idx > DEPTH-1-8; idx = idx-1) begin
    @ (negedge clk) begin
      GenerateTest(.read(1), .write(0), .addr_input(idx), .addr_source(USE_INPUT_ADDR));
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
      GenerateTest(.read(1), .write(1), .addr_input(idx), .addr_source(USE_INPUT_ADDR));
    end
    @ (posedge clk) begin
      Test;
    end
  end
  // test mem[n-2, n-1]
  for (idx = DEPTH-1; idx > DEPTH-1-2; idx = idx-1) begin
    @ (negedge clk) begin
      GenerateTest(.read(1), .write(1), .addr_input(idx), .addr_source(USE_INPUT_ADDR));
    end
    @ (posedge clk) begin
      Test;
    end
  end


  // Stochastic Test
  repeat (2 ** 6) begin
    @ (negedge clk) begin
      GenerateTest(.read(0), .write(1), .addr_input(0), .addr_source(USE_RANDOM_ADDR));
    end
    @ (posedge clk) begin
      Test;
    end
    @ (negedge clk) begin
      GenerateTest(.read(1), .write(0), .addr_input(0), .addr_source(USE_RANDOM_ADDR));
    end
    @ (posedge clk) begin
      Test;
    end
  end

  $finish;
end

task PrintErr;
begin
   $display("[ERROR]");
    $write("ren: %d\n", ren);
    $write("wen: %d\n", wen);
    $write("din: %d\n", din);
    $write("addr: %d\n", addr);
    $write("dout: %d\n", dout);
    $write("out : %d\n", out);
    $display;
end
endtask

task Test;
    begin
        // FIXME: solve undesired delay
        // There will be a dout delay when read/write change, havn't find a good
        // solution yet. Use clock/4 delay to solve for now.
        # (`CYC/4) 
        if (dout !== out) begin
          PrintErr;
        end 
    end
endtask


task GenerateTest;
    input read;
    input write;
    input [7-1:0] addr_input;
    input addr_source;
    
    begin
        // generate
        ren = read;
        wen = write;
        din = $urandom_range(0, 256-1);
        if (addr_source == USE_RANDOM_ADDR) begin
          addr = $urandom_range(0, 128-1);
        end
        else begin
          addr = addr_input;
        end
    
        // udpate answer
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
