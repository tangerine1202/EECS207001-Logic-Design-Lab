`timescale 1ns/1ps

/**
 *  
 *  Collect all lib/ modules into a single module for clearity.
 * 
*/
module LibCollect ();

// Cmp
reg eq_out, eq_a, eq_b;
reg ge_out, ge_a, ge_b;
reg gt_out, gt_a, gt_b;
reg le_out, le_a, le_b;
reg lt_out, lt_a, lt_b;

Eq_1bit (eq_out, eq_a, eq_b);
Ge_1bit (ge_out, ge_a, ge_b);
Gt_1bit (gt_out, gt_a, gt_b);
Le_1bit (le_out, le_a, le_b);
Lt_1bit (lt_out, lt_a, lt_b);

// FullAdder
reg fa_a, fa_b, fa_cin, fa_cout, fa_sum;
FullAdder (fa_sum, fa_cout, fa_a, fa_b, fa_cin);

// Mux
reg mux1_in0, mux1_in1, mux1_out, mux_sel;
reg [3-1:0] mux3_in0, mux3_in1, mux3_out;
reg [4-1:0] mux4_in0, mux4_in1, mux4_out;
reg [8-1:0] mux8_in0, mux8_in1, mux8_out;

Mux_1bit  (.out(mux1_out), .in1(mux1_in1), .in0(mux1_in0), .sel(mux_sel));
Mux_3bits (.out(mux3_out), .in1(mux3_in1), .in0(mux3_in0), .sel(mux_sel));
Mux_4bits (.out(mux4_out), .in1(mux4_in1), .in0(mux4_in0), .sel(mux_sel));
Mux_8bits (.out(mux8_out), .in1(mux8_in1), .in0(mux8_in0), .sel(mux_sel));

// Decoder
reg [3-1:0] dec_out, dec_sel;

Decoder_3x8 (dec_out, dec_sel);


endmodule