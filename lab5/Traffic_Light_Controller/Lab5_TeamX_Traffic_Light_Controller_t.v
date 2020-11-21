`timescale 1ns/1ps
`define CYC 4

module Traffic_Light_Controller_t ();

// Traffic lights
parameter GREEN  = 3'b100;
parameter YELLOW = 3'b010;
parameter RED    = 3'b001;

// States
parameter HW_G = 3'd0;
parameter HW_G2Y = 3'd1;
parameter HW_Y = 3'd2;
parameter HW_R = 3'd3;
parameter LR_G = 3'd4;
parameter LR_Y = 3'd5;
parameter LR_R = 3'd6;
parameter ERR_STATE = 3'd7;

// IO ports
reg clk = 1'b1;
reg rst_n = 1'b1;
reg lr_has_car = 1'b0;
wire [3-1:0] hw_light;
wire [3-1:0] lr_light;

always #(`CYC/2) clk = ~clk;

Traffic_Light_Controller Q2 (
  .clk(clk),
  .rst_n(rst_n),
  .lr_has_car(lr_has_car),
  .hw_light(hw_light),
  .lr_light(lr_light)
);

initial begin
  #(`CYC/2) rst_n = 1'b0;
  #`CYC rst_n = 1'b1;

  #(`CYC * (3-1)) lr_has_car = 1'b1;
  #(`CYC * 13)


  #(`CYC/2) rst_n = 1'b0;
  #`CYC rst_n = 1'b1;

  #(`CYC * 5) lr_has_car = 1'b1;
  #(`CYC * 13)

  $finish;
end


endmodule
