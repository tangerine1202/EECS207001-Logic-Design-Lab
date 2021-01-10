module Receive_From_Arduino (
  input clk,
  input rst,
  input SerialFromArduino,
  output [15:0] led
);

//parameter CLK_FREQ  = 32'd100_000_000;
//parameter UART_BAUD = 32'115200;
parameter CLKS_PER_BIT = 32'd868;  // CLK_FREQ/UART_BAUD


reg [7:0] data;
wire rx_ready;
wire [7:0] rx_byte;


always @(posedge clk) begin
  if (rst == 1'b1)
    data[7:0] <= 8'b0000_0000;
  else begin
    if (rx_ready == 1'b1)
      data[7:0] <= rx_byte[7:0];
    else
      data[7:0] <= data[7:0];
  end
end

assign led[7:0] = data[7:0];


// Checked: Serial will transmit 0 and 1 
// FIXME: rx_ready never raise to 1
// test SerialFromArduino port

assign led[8] = (uart_state == 3'd0) ? 1'b1 : 1'b0;
assign led[9] = (uart_state == 3'd1) ? 1'b1 : 1'b0;
assign led[10] = (uart_state == 3'd2) ? 1'b1 : 1'b0;
assign led[11] = (uart_state == 3'd3) ? 1'b1 : 1'b0;
assign led[12] = (uart_state == 3'd4) ? 1'b1 : 1'b0;
assign led[15] = SerialFromArduino;


uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) rx_from_uart (
  .i_Clock(clk),
  .i_Rx_Serial(SerialFromArduino),
  .o_Rx_DV(rx_ready),
  .o_Rx_Byte(rx_byte),
  .r_SM_Main(uart_state)
);

endmodule