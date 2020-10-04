`timescale 1ns/1ps

module Gate_1bit_in_aanb;
reg a = 1'b0;
reg b = 1'b0;

wire out_not;
Not_1bit_in_aanb not_1bit_in_aanb (out_not, a);

wire out_and, out_nor;
And_1bit_in_aanb and_1bit_in_aanb (out_and, a, b);
Nor_1bit_in_aanb nor_1bit_in_aanb (out_nor, a, b);

wire out_nand, out_or;
Nand_1bit_in_aanb nand_1bit_in_aanb (out_nand, a, b);
Or_1bit_in_aanb or_1bit_in_aanb (out_or, a, b);

wire out_xor, out_xnor;
Xor_1bit_in_aanb xor_1bit_in_aanb (out_xor, a, b);
Xnor_1bit_in_aanb xnor_1bit_in_aanb (out_xnor, a, b);


initial begin
    repeat (2 ** 2) begin
        #1 {a, b} = {a, b} + 1'b1;
    end
    #1 $finish;
end

endmodule