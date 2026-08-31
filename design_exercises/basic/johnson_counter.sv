// **************************************************************************************
// @file spim.sv
// @brief Design implementation of a SPI Master core.
//
// status: wip
// **************************************************************************************
// MIT License
//
// Copyright (c) 2026 Miguel Ugsimar
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// **************************************************************************************
//
// Johnson counter aka twisted-ring, switch tail ring, or mobius counter is
// a circular shift register counter constructed in a circular flip-flop
// manner, wherein the output of a flip-flop is fed to the next stage and the
// output of the last stage is fed back to the first stage.
//
//  state | cnt[0] | cnt[1] | cnt[2] | cnt[3] 
// -------+--------+--------+--------+--------
//   0    |   0    |   0    |   0    |   0
//   1    |   1    |   0    |   0    |   0
//   2    |   1    |   1    |   0    |   0
//   3    |   1    |   1    |   1    |   0
//   4    |   1    |   1    |   1    |   1
//   5    |   0    |   1    |   1    |   1
//   6    |   0    |   0    |   1    |   1
//   7    |   0    |   0    |   0    |   1
//
// you might think, why only 8-states? if there are 4 bits, there must be
// 16-states? because of its feedback nature, it only permits upto 8-states.
//
//          the inverted output at the last stage is fed back
//       +----------------------------------------------------------------------------+
//       |   +-------+          +-------+          +-------+          +-------+       |
//       +-->|d     q|--q[0]--->|d     q|--q[1]--->|d     q|--q[2]--->|d     q|--q[3] |
// clk---+-->|clk  ~q|      +-->|clk  ~q|      +-->|clk  ~q|      +-->|clk  ~q|-------+
//       |   +-------+      |   +-------+      |   +-------+      |   +-------+      
//       +------------------+------------------+------------------+
//
// Johnson countr is also considered as a special case LFSR.
//
// Possible application:
//  > clock division, it can divide by 2*n
//  > multi-phase clock generation
//  > sequential state fsm
//  > pattern generation
// **************************************************************************************/

module johnson_counter #(
  // number of states
  // TODO: use generator to make this bit configurable
  parameter int N_STATES=8,
  // TODO: number of stages
  parameter int N_BIT=(N_STATES >> 1)
)(
  output logic o_out,
);
  logic [3:0] q;

  // assign to last msb
  assign o_out = q[N-1];

  always @(posedge clk)
    begin
    if(reset)
      q=4'd0;
    else begin 
      q[3] <= q[2];
      q[2] <= q[1];
      q[1] <= q[0];
      q[0] <= ~q[3];
    end
  end

endmodule


