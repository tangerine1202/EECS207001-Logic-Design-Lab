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
  // No Read Write
  repeat (2 ** 2) begin
    @ (negedge clk) begin
      Test(
        .read(0), 
        .write(0)
      );
    end
  end
  // Read Write at the same time
  repeat (2 ** 2) begin
    @ (negedge clk) begin
      Test(
        .read(1), 
        .write(1)
      );
    end
  end

  repeat(2 ** 2) begin
    // Write
    repeat(2 ** 3) begin
      @ (negedge clk) begin
        Test(
          .read(0), 
          .write(1)
        );
      end
    end
    // Read  
    repeat(2 ** 3) begin
      @ (negedge clk) begin
        Test(
          .read(1), 
          .write(0)
        );
      end
    end
  end

  // No Read Write
  repeat (2 ** 2) begin
    @ (negedge clk) begin
      Test(
        .read(0), 
        .write(0)
      );
    end
  end
  // Read Write at the same time
  repeat (2 ** 2) begin
    @ (negedge clk) begin
      Test(
        .read(1), 
        .write(1)
      );
    end
  end
  $finish;
end

task Test;
    input read;
    input write;
    begin
      ren = read;
      wen = write;
      // FIXME: large range is hard to test, need to figure out a better ways
      addr = $urandom_range(0, 16-1);
      din = $urandom_range(0, 256-1);
    end
endtask

endmodule
