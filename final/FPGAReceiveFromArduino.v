module Receive_From_Arduino (
  input clk,
  input rst,
  input SerialFromArduino,
  output [8:0] LED
);

parameter IDLE = 1'b0;
parameter RECV = 1'b1;

//parameter CLK_FREQ  = 32'd100_000_000;
//parameter UART_BAUD = 32'd9600;
parameter CLKS_PER_BIT = 10417;  // CLK_FREQ/UART_BAUD


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

assign LED[7:0] = data[7:0];

// Checked: Serial will trasmit 0 and 1 
// FIXME: rx_ready never raise to 1
// test SerialFromArduino port
reg sfa_state;
reg next_sfa_state;
always @(posedge clk) begin
  if (rst == 1'b1)
    sfa_state <= 1'b0;
  else  
    sfa_state <= next_sfa_state;
end

always @(*) begin
  if (rx_ready == 1'b1)
    next_sfa_state = 1'b1;
  else
    next_sfa_state = sfa_state;
end

assign LED[8] = sfa_state;


uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) rx_from_uart (
  .i_Clock(clk),
  .i_Rx_Serial(SerialFromArduino),
  .o_Rx_DV(rx_ready),
  .o_Rx_Byte(rx_byte)
);

endmodule