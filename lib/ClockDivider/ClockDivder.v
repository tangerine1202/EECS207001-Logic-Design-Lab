`timescale 1ns/1ps

module Clock_divider (clk_out, clk_refresh, origin_clk, rst_n);

input origin_clk;
input rst_n;
output clk_out;
output clk_refresh;

parameter CLK_PER_OUT = 1_000 - 1;     // 1M clk / sec
parameter CLK_PER_REFRESH = 100 - 1;  // 1M clk / sec

// parameter CLK_PER_OUT = 100;     // 1M clk / sec
// parameter CLK_PER_REFRESH = 10;  // 1M clk / sec

reg [32-1:0] cnt_out;      // origin_clk => 1 clk_out
reg [32-1:0] cnt_refresh;  // origin_clk => 1 clk_refresh 

// Sequential
always @(posedge origin_clk) begin
    if (rst_n == 1'b0) begin
        cnt_out <= 32'b0;
        cnt_refresh <= 32'b0;
    end
    else begin
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
end

assign clk_out = (cnt_out == CLK_PER_OUT) ? 1'b1 : 1'b0;
assign clk_refresh = (cnt_refresh == CLK_PER_REFRESH) ? 1'b1 : 1'b0;

endmodule