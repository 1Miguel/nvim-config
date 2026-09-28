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
module uart_edge_detect(
  input logic clk_i,
  input logic rst_n_i,
  input logic sig_i,
  output logic pos_o,
  output logic neg_o,
  output logic both_o
);

  logic sig;

  assign pos_o = (~sig & sig_i); 
  assign neg_o = (sig & ~sig_i);  
  assign both_o = ~(sig ^ ~sig_i);  

  always_ff @(posedge clk_i) begin
    if (!rst_n_i)
      sig <= '0;
    else
      sig <= sig_i;
  end
endmodule : uart_edge_detect
