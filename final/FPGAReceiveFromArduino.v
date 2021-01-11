module Receive_From_Arduino (
  input clk,
  input rst,
  input serialFromArduino,
  output reg [15:0] data,
  output isDataReady;
  // debug
  output [15:0] led,
  output [3:0] an,
  output [6:0] seg
);

//parameter CLK_FREQ  = 32'd100_000_000;
//parameter UART_BAUD = 32'115200;
parameter CLKS_PER_BIT = 32'd868;  // CLK_FREQ / UART_BAUD

parameter IDLE = 2'd0;
parameter RX_MSB = 2'd1;
parameter RX_LSB = 2'd2;
parameter DATA_READY = 2'd3;

wire rxReady;
wire [7:0] rxByte;
reg [1:0] state;
reg [1:0] nextState;

always @(posedge clk) begin
  if (rst == 1'b1) begin
    data = 16'd0;
    state <= RX_MSB;
  end
  else begin
    state <= next_state;
  end
end

always @(*) begin
  case (state)
    RX_MSB: begin
      if (rxReady == 1'b1) begin
        data[15:8] = rxByte[7:0];
        data[7:0] = data[7:0];
        nextState = RX_LSB;
      end
      else begin
        data = data;
        nextState = RX_MSB;
      end
    end
    RX_LSB: begin
      if (rxReady == 1'b1) begin
        data[15:8] = data[15:8];
        data[7:0] = rxByte[7:0];
        nextState = DATA_READY;
      end
      else begin
        data = data;
        nextState = RX_LSB;
      end
    end
    DATA_READY: begin
      data = data;
      nextState = RX_MSB;
    end
    default: begin
      data = data;
      nextState = RX_MSB;
    end
end

assign isDataReady = (state == DATA_READY) ? 1'b1 : 1'b0;

// debug
assign led[15:0] = data[15:0];

NumToSeg num2seg (
  .clk(clk),
  .num(data),
  .seg(seg),
  .an(an)
);

uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) rx_from_uart (
  .i_Clock(clk),
  .i_Rx_Serial(serialFromArduino),
  .o_Rx_DV(rxReady),
  .o_Rx_Byte(rxByte)
);

endmodule