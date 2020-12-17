`timescale 1ns/1ps

module sonic_top(clk, rst, Echo, Trig, stop, dis);
  // [TO-DO] calculate the right distance to trig stop(triggered when the distance is lower than 40 cm)
  // Hint: using "dis"

	input clk, rst, Echo;
	output Trig, stop;
	output [19:0] dis;

	wire [19:0] d;
  wire clk1M;
	wire clk_2_17;

  div clk1(clk ,clk1M);
	TrigSignal u1(.clk(clk), .rst(rst), .trig(Trig));
	PosCounter u2(.clk(clk1M), .rst(rst), .echo(Echo), .distance_count(dis));

  assign stop = (dis < 20'd4000) ? 1'b1 : 1'b0;

endmodule

module PosCounter(clk, rst, echo, distance_count);
  input clk, rst, echo;
  output[19:0] distance_count;

  parameter S0 = 2'b00;
  parameter S1 = 2'b01;
  parameter S2 = 2'b10;

  wire start, finish;
  reg [1:0] curr_state, next_state;
  reg echo_reg1, echo_reg2;
  reg [19:0] count, distance_register;
  wire [19:0] distance_count;

  always@(posedge clk) begin
    if(rst) begin
      echo_reg1 <= 0;
      echo_reg2 <= 0;
      count <= 0;
      distance_register  <= 0;
      curr_state <= S0;
    end
    else begin
      echo_reg1 <= echo;
      echo_reg2 <= echo_reg1;
      case (curr_state)
        S0:begin
          if (start) curr_state <= next_state; //S1
          else count <= 0;
        end
        S1:begin
          if (finish) curr_state <= next_state; //S2
          else count <= count + 1;
        end
        S2:begin
          distance_register <= count;
          count <= 0;
          curr_state <= next_state; //S0
        end
      endcase
    end
  end

  always @(*) begin
    case (curr_state)
      // FIXME: TA use blocking assign in Combinational Circuit?
//       S0: next_state <= S1;
//       S1: next_state <= S2;
//       S2: next_state <= S0;
      S0: next_state = S1;
      S1: next_state = S2;
      S2: next_state = S0;
    endcase
  end

  /* distance_count (cm)
    c = 331.5 + 0.607 * t (m/s)
    If temperature = 20 (C degree):
      c = 0.034364 (cm/us)
          -> 29.1  (us/cm)
      distance_count = (traveled_time(us) / 2) * (c)  (cm)
                     = (traveled_time(us) / 2) / 29.1 (cm)
                     = (traveled_time(us)) * 100 / 58   (00.00cm)
  */
  assign distance_count = distance_register  * 100 / 58;
  assign start = echo_reg1 & ~echo_reg2;
  assign finish = ~echo_reg1 & echo_reg2;
endmodule

module TrigSignal(clk, rst, trig);
  input clk, rst;
  output trig;

  reg trig, next_trig;
  reg [23:0] count, next_count;

  always @(posedge clk, posedge rst) begin
    if (rst) begin
      count <= 0;
      trig <= 0;
    end
    else begin
      count <= next_count;
      trig <= next_trig;
    end
  end

  always @(*) begin
    next_trig = trig;
    next_count = count + 1;
    if(count == 999)
      next_trig = 0;
    else if(count == 24'd9_999_999) begin
      next_trig = 1;
      next_count = 0;
    end
  end
endmodule

module div(clk, out_clk);
  input clk;
  output reg out_clk;
  // reg clkout;
  reg [6:0] cnt;

  always @(posedge clk) begin
    if(cnt < 7'd50) begin
      cnt <= cnt + 1'b1;
      out_clk <= 1'b1;
    end
    else if(cnt < 7'd100) begin
      cnt <= cnt + 1'b1;
      out_clk <= 1'b0;
    end
    else if(cnt == 7'd100) begin
      cnt <= 0;
      out_clk <= 1'b1;
    end
  end
endmodule