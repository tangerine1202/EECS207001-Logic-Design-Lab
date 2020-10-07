`timescale 100ps/1ps

module Decode_and_Execute_t;

parameter SIZE = 4;

reg CLK = 1;

reg [3-1:0] op_code = 3'b0;
reg [SIZE-1:0] rs = 4'b0;
reg [SIZE-1:0] rt = 4'b0;
wire [SIZE-1:0] rd;


Decode_and_Execute dae_0 (
  .op_code(op_code),
  .rs(rs),
  .rt(rt),
  .rd(rd)
);

always #1 CLK = ~CLK;

initial begin
  op_code = 3'b000;
  repeat (2 ** 3) begin
    {rs, rt} = 8'b0;
    repeat (2 ** 8) begin
      @ (posedge CLK)
        Test;
      @ (negedge CLK)
        {rs, rt} = {rs, rt} + 8'b1;
    end
    op_code = op_code + 3'b001;
  end
  /*
  // ADD 
  op_code = 3'b000;
  {rs, rt} = 8'b0;
  repeat (2 ** 8) begin
    @ (posedge CLK)
      Test;
    @ (negedge CLK)
      {rs, rt} = {rs, rt} + 8'b1;
  end
  // SUB
  op_code = 3'b001;
  {rs, rt} = 8'b0;
  repeat (2 ** 8) begin
    @ (posedge CLK)
      Test;
    @ (negedge CLK)
      {rs, rt} = {rs, rt} + 8'b1;
  end
  // INC
  op_code = 3'b010;
  {rs, rt} = 8'b0;
  repeat (2 ** 8) begin
    @ (posedge CLK)
      Test;
    @ (negedge CLK)
      {rs, rt} = {rs, rt} + 8'b1;
  end
  */
/*
  // BITWISE_NOR 
  op_code = 3'b011;
  {rs, rt} = 8'b0;
  repeat (2 ** 8) begin
    @ (posedge CLK)
      Test;
    @ (negedge CLK)
      {rs, rt} = {rs, rt} + 8'b1;
  end
  // BITWISE_NAND 
  op_code = 3'b100;
  {rs, rt} = 8'b0;
  repeat (2 ** 8) begin
    @ (posedge CLK)
      Test;
    @ (negedge CLK)
      {rs, rt} = {rs, rt} + 8'b1;
  end
  // RS DIV 4 
  op_code = 3'b101;
  {rs, rt} = 8'b0;
  repeat (2 ** 8) begin
    @ (posedge CLK)
      Test;
    @ (negedge CLK)
      {rs, rt} = {rs, rt} + 8'b1;
  end
  // RS MUL 2 
  op_code = 3'b110;
  {rs, rt} = 8'b0;
  repeat (2 ** 8) begin
    @ (posedge CLK)
      Test;
    @ (negedge CLK)
      {rs, rt} = {rs, rt} + 8'b1;
  end
  // MUL
  op_code = 3'b111;
  {rs, rt} = 8'b0;
  repeat (2 ** 8) begin
    @ (posedge CLK)
      Test;
    @ (negedge CLK)
      {rs, rt} = {rs, rt} + 8'b1;
  end
  */
  
  #1 $finish;
end


task Test;
begin
  case (op_code)
    3'b000:
      // ADD
      if (rd !== rs + rt) begin
        $display("[ERROR] ADD");
        $write("rs: %d\n", rs);
        $write("rt: %d\n", rt);
        $write("rd: %d\n", rd);
        $write("expect: %d\n", rs + rt);
        $display;
      end
    3'b001:
      // SUB
      if (rd !== rs - rt) begin
        $display("[ERROR] SUB");
        $write("rs: %d\n", rs);
        $write("rt: %d\n", rt);
        $write("rd: %d\n", rd);
        $write("expect: %d\n", rs - rt);
        $display;
      end
    3'b010:
    // INC;
      if (rd !== rs + 4'b1) begin
        $display("[ERROR] INC");
        $write("rs: %d\n", rs);
        $write("rt: %d\n", rt);
        $write("rd: %d\n", rd);
        $write("expect: %d\n", rs + 4'b1);
        $display;
      end
    3'b011:
      // BITWISE_NOR
      if (rd !== ~(rs | rt)) begin
        $display("[ERROR] BITWISE_NOR");
        $write("rs: %d\n", rs);
        $write("rt: %d\n", rt);
        $write("rd: %d\n", rd);
        $write("expect: %d\n", ~(rs | rt));
        $display;
      end
    3'b100:
      // BITWISE_NAND 
      if (rd !== ~(rs & rt)) begin
        $display("[ERROR] BITWISE_NAND");
        $write("rs: %d\n", rs);
        $write("rt: %d\n", rt);
        $write("rd: %d\n", rd);
        $write("expect: %d\n", ~(rs & rt));
        $display;
      end
    3'b101:
      // RS DIV 4
      if (rd !== rs >> 2) begin
        $display("[ERROR] RS DIV 4");
        $write("rs: %d\n", rs);
        $write("rt: %d\n", rt);
        $write("rd: %d\n", rd);
        $write("expect: %d\n", rs >> 2);
        $display;
      end
    3'b110:
      // RS MUL 2
      if (rd !== rs << 1) begin
        $display("[ERROR] RS MUL 2");
        $write("rs: %d\n", rs);
        $write("rt: %d\n", rt);
        $write("rd: %d\n", rd);
        $write("expect: %d\n", rs << 1);
        $display;
      end
    3'b111:
      // MUL
      if (rd !== rs * rt) begin
        $display("[ERROR] MUL");
        $write("rs: %d\n", rs);
        $write("rt: %d\n", rt);
        $write("rd: %d\n", rd);
        $write("expect: %d\n", rs * rt);
        $display;
      end
    default:
      $display("[ERROR] unknown op_code: %d", op_code);
  endcase
end
endtask

endmodule
