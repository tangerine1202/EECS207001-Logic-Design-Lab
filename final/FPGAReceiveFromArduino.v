module Receive_From_Arduino (
  input clk,
  input rst,
  input SerialFromArduino,
  output [15:0] led
);

//parameter CLK_FREQ  = 32'd100_000_000;
//parameter UART_BAUD = 32'115200;
parameter CLKS_PER_BIT = 32'd868;  // CLK_FREQ/UART_BAUD


reg [15:0] data;
wire rx_ready;
wire [7:0] rx_byte;
reg high_bits;


always @(posedge clk) begin
  if (rst == 1'b1) begin
    data[15:0] <= 16'b0000_0000_0000_0000;
    high_bits <= 1'b1;
  end
  else begin
    if (high_bits == 1'b1) begin
      if (rx_ready == 1'b1) begin
        data[15:8] <= rx_byte[7:0];
        high_bits <= 1'b0;
      end
      else begin
        data[15:0] <= data[15:0];
      end
    end
    else begin
      if (rx_ready == 1'b1)
        data[7:0] <= rx_byte[7:0];
      else
        data[15:0] <= data[15:0];
    end
  end
end

assign led[15:0] = data[15:0];


uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) rx_from_uart (
  .i_Clock(clk),
  .i_Rx_Serial(SerialFromArduino),
  .o_Rx_DV(rx_ready),
  .o_Rx_Byte(rx_byte),
  .r_SM_Main(uart_state)
);

endmodule