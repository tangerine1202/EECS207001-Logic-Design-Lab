`timescale 1ns/1ps 

module Parameterized_Ping_Pong_Counter (clk, rst_n, enable, flip, max, min, direction, out);
input clk, rst_n;
input enable;
input flip;
input [4-1:0] max;
input [4-1:0] min;
output direction;
output [4-1:0] out;

reg drct;
reg [4-1:0] cnt;

always @(posedge clk) begin
    if(rst_n == 0)
        drct = 1'b1;
    else begin
        if(flip==1 || cnt==max || cnt==min)
            ch_drct();
    end
end

always @(posedge clk) begin
    if(rst_n == 0)
        cnt = min;
    else begin
        if (enable && max > min) begin
            if (drct) begin
                if(cnt < max)
                    cnt = cnt + 1'b1;
                else if (cnt == max)
                    cnt = cnt - 1'b1; 
            end
            else begin
                if(cnt > min)
                    cnt = cnt - 1'b1;
                else if (cnt == min)
                    cnt = cnt + 1'b1; 
            end
        end
    end
end

/*
always @(posedge clk) begin
    if (rst_n == 0) begin
        drct = 1'b1;
        cnt = min;
    end
    else begin
        if(flip == 1) begin
            ch_drct();
        end
        if (enable && max > min) begin
            if (drct) begin
                if(cnt < max)
                    cnt = cnt + 1'b1;
                else if (cnt == max) begin
                    ch_drct();
                    cnt = cnt - 1'b1; 
                end
            end
            else begin
                if(cnt > min)
                    cnt = cnt - 1'b1;
                else if (cnt == min) begin
                    ch_drct();
                    cnt = cnt + 1'b1; 
                end
            end
        end
    end
end
*/

assign direction = drct;
assign out = cnt;

task ch_drct;
begin
    drct = !drct;
end
endtask

endmodule
