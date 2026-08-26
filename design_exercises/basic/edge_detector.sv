
`timescale 1ns/1ps
// a simple implementations of edge detection circuit. the operation is simple,
// if an edge is detected, then the output generates a small pulse.
//
//  i ___|¯¯¯¯¯|___|¯¯¯¯¯|___|¯¯¯¯¯|___|¯¯¯¯¯|___|¯¯¯¯¯|___|¯¯¯¯¯|
//  p ____|¯|_______|¯|_______|¯|_______|¯|_______|¯|_______|¯|
//  n __________|¯|_______|¯|_______|¯|_______|¯|_______|¯|_______|¯|
//  b ____|¯|___|¯|_|¯|___|¯|_|¯|___|¯|_|¯|___|¯|_|¯|___|¯|_|¯|___|¯|
//
//  note that the edge detection must be configurable to detect:
//    > pos edge only
//    > neg edge only
//    > both edge
//
// we can create a truth table:
//  prev curr pos_edge neg_edge both_edge
//   0    0      0        0        0
//   1    0      0        1        1
//   0    1      1        0        1
//   1    1      0        0        0
//
//  and with sum-of-products, we can deduce:
//  pos edge detection:
//    out = ~prev & curr
//  neg edge detection:
//    out = prev ^ ~curr;
//  both edge detection:
//    out = ~(prev ^ curr);
//
//  it is up to the reader how those boolean equations were deduced :)
module edge_detector(
  input logic i_clk,
  input logic i_rst_n,
  input logic i_sig,
  output logic o_pos_edge,
  output logic o_neg_edge,
  output logic o_both_edge
);

  logic sig;

  assign o_pos_edge = (~sig & i_sig); 
  assign o_neg_edge = (sig & ~i_sig);  
  assign o_both_edge = ~(sig ^ ~i_sig);  

  always_ff @(posedge i_clk) begin
    if (!i_rst_n)
      sig <= '0;
    else
      sig <= i_sig;
  end
endmodule;
