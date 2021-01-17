module Receive_From_Arduino (
  input clk,
  input rst,
  input serialFromArduino,
  output reg [15:0] data,
  output isDataReady
);

  //parameter CLK_FREQ  = 32'd100_000_000;
  //parameter UART_BAUD = 32'd115_200;
  parameter CLKS_PER_BIT = 32'd868;  // CLK_FREQ / UART_BAUD

  parameter RX_MSB = 2'd1;        // the state ready to receive MSB
  parameter RX_LSB = 2'd2;        // the state ready to receive LSB
  parameter DATA_READY = 2'd3;

  wire rxReady;                   // data from uart module is ready
  wire [7:0] rxByte;              // data from uart module
  reg [15:0] nextData;
  reg [1:0] state;
  reg [1:0] nextState;


  uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) rx_from_uart (
    .i_Clock(clk),
    .i_Rx_Serial(serialFromArduino),
    .o_Rx_DV(rxReady),
    .o_Rx_Byte(rxByte)
  );

  always @(posedge clk) begin
    if (rst == 1'b1) begin
      data <= 16'd0;
      state <= RX_MSB;
    end
    else begin
      data <= nextData;
      state <= nextState;
    end
  end

  always @(*) begin
    case (state)
      RX_MSB: begin
        if (rxReady == 1'b1) begin
          nextData[15:8] = rxByte[7:0];
          nextData[7:0] = data[7:0];
          nextState = RX_LSB;
        end
        else begin
          nextData = data;
          nextState = RX_MSB;
        end
      end
      RX_LSB: begin
        if (rxReady == 1'b1) begin
          nextData[15:8] = data[15:8];
          nextData[7:0] = rxByte[7:0];
          nextState = DATA_READY;
        end
        else begin
          nextData = data;
          nextState = RX_LSB;
        end
      end
      DATA_READY: begin
        nextData = data;
        nextState = RX_MSB;
      end
      default: begin
        nextData = data;
        nextState = RX_MSB;
      end
    endcase
  end

  assign isDataReady = (state == DATA_READY) ? 1'b1 : 1'b0;

endmodule