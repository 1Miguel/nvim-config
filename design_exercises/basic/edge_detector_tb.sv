// **************************************************************************************
// @file edge_detector_tb.sv
// @brief simple edge detection testbench
// **************************************************************************************
// run this with verilator:
//    'verilator --binary --exe --timing --trace-vcd --top-module edge_detector_tb edge_detector_tb.sv edge_detector.sv'
// **************************************************************************************

`timescale 1ns/1ps

localparam int N=100;

module edge_detector_tb ();

  logic clk;
  logic rst;
  logic sig;
  logic pos_edge;
  logic neg_edge;
  logic both_edge;

  edge_detector dut(
    .i_clk(clk),
    .i_rst_n(rst),
    .i_sig(sig),
    .o_pos_edge(pos_edge),
    .o_neg_edge(neg_edge),
    .o_both_edge(both_edge)
  );

  clock_gen#(.TICK(5)) u_clk_gen(.o_clk(clk));

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb);

    clk = 0;
    rst = 0;
    #1
    rst = 1;

    fork
      repeat(N) #100 sig = ~sig;
      // TODO: signal checker if edges were triggered correctly
    join_any

    $finish;
  end

endmodule
