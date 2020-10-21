`timescale 1ns/1ps

module Flip_LED (out_ld, out_n_ld, refresh_ld, refresh_n_ld, rst_n_one_pulse, rst_n, clk);

input clk;
input rst_n;
output reg out_ld;
output reg refresh_ld;
output out_n_ld;
output refresh_n_ld;
output rst_n_one_pulse;

assign out_n_ld = ~out_ld;
assign refresh_n_ld = ~refresh_ld;

// utils clk
wire clk_out;
wire clk_refresh;
// debounce and one_pluse
wire rst_n_debounced;
//wire rst_n_one_pulse;

Clock_divider cd (
  .clk_out(clk_out),
  .clk_refresh(clk_refresh),
  .origin_clk(clk)
);

Debounce debounce_rst_n (
   .pb_debounced(rst_n_debounced),
   .pb(rst_n),
   .clk(clk_refresh)
);
One_pulse one_pluse_rst_n (
   .pb_one_pluse(rst_n_one_pulse),
   .pb_debounced(rst_n_debounced),
   .clk(clk_refresh)
);


// SC
always @(posedge clk_out) begin
  if (rst_n_one_pulse == 1'b0) begin
    out_ld <= 1'b0;
  end
  else begin
    out_ld <= ~out_ld;
  end
end

// SC
always @(posedge clk_refresh) begin
  if (rst_n_one_pulse == 1'b0) begin
    refresh_ld <= 1'b0;
  end
  else begin
    refresh_ld <= ~refresh_ld;
  end
end

endmodule

module Clock_divider (clk_out, clk_refresh, origin_clk);//, rst_n);

input origin_clk;
output clk_out;
output clk_refresh;

parameter CLK_PER_OUT = 10_000 - 1;     // 1M clk / sec
parameter CLK_PER_REFRESH = 1000 - 1;  // 1M clk / sec

reg [32-1:0] cnt_out;      // origin_clk => 1 clk_out
reg [32-1:0] cnt_refresh;  // origin_clk => 1 clk_refresh 

// Sequential
always @(posedge origin_clk) begin
  if (cnt_out == CLK_PER_OUT) begin
      cnt_out <= 32'b0;
  end
  else begin
      cnt_out <= cnt_out + 32'b1;
  end
  if (cnt_refresh == CLK_PER_REFRESH) begin
      cnt_refresh <= 32'b0;
  end
  else begin
      cnt_refresh <= cnt_refresh + 32'b1;
  end
end

assign clk_out = (cnt_out == CLK_PER_OUT) ? 1'b1 : 1'b0;
assign clk_refresh = (cnt_refresh == CLK_PER_REFRESH) ? 1'b1 : 1'b0;

endmodule



// Debounce submodule
module Debounce (pb_debounced, pb, clk);

input pb;
input clk;
output pb_debounced;

reg [4-1:0] dff;

always @(posedge clk) begin
    dff[3:1] <= dff[2:0];
    dff[0] <= pb;
end

assign pb_debounced = (dff == 4'b0000) ? 1'b0 : 1'b1;

endmodule

// One pluse submodule
module One_pulse (pb_one_pluse, pb_debounced, clk);

input pb_debounced;
input clk;
output reg pb_one_pluse;

reg pb_debounced_delay;

always @(posedge clk) begin
    pb_one_pluse <= pb_debounced | (!pb_debounced_delay);
    pb_debounced_delay <= pb_debounced;
end

endmodule