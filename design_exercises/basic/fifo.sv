// **************************************************************************************
// @file fifo.sv
// @brief A simple implementation of a fifo
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

module fifo #(
  // N size of registers
  parameter int unsigned N=32,
  // fifo depth
  parameter int unsigned DEPTH=16,
  // the width of the pointer must have the required range set by
  // the DEPTH i.e if the depth is set to 8 < n <= 16, N_PTR must
  // be set to `4`
  localparam int unsigned N_PTR = (DEPTH <= 2) ? 1 : $clog2(DEPTH)
) (
  input i_clk,
  input i_rst_n,
  input logic [N:0] i_push_data,
  input i_push,
  input i_pop,
  output logic [N:0] o_pop_data,
  output o_full,
  output o_empty,
  output [N_PTR:0] o_level
);

  // we will create a local parameter `depth` that has the type that matches
  // the size of [N_PTR:0], this is useful when comparing with levels
  localparam [N_PTR:0] depth = (N_PTR+1)'(DEPTH);
  localparam [N_PTR-1:0] max_idx = (N_PTR)'(depth) - 1;
  logic [DEPTH-1:0][N:0] mem;
  logic [N_PTR-1:0] w_idx; // write index ptr
  logic [N_PTR-1:0] r_idx; // read index ptr

  assign o_full = (o_level == depth);
  assign o_empty = (o_level == 0);

  // below is a `procedural block` and is a container for programming
  // statements. the purpose of `procedural block` is to control when these
  // programming statements should execute i.e @(posedge i_clk) indicates that
  // the programming statements executes whenever `i_clk` signal changes.
  //
  // below is an `always` procedure. `always` procedure is an inifinite loop.
  // its simple, when the hardware powers up, it will continuously do this
  // behavior.
  //
  // we could use general purpose `always` procedural block i.e
  //
  //    always @(posedge i_clk) ...
  //
  // it is useful and flexible but because of its flexibility, it makes it
  // difficult for software tools and synthesizers to identify the intended
  // usage of `always block`.
  //
  // in our case, we will use specialize `always_ff` procedural block. it
  // imposes synthesis restriction (such as no combinational circuit inside)
  // for modeling sequential logic devices such as flip-flops.
  //
  // below is what we call sensitivity list. senstivity list controls the
  // program execution within an `always` block. sensitivity list can be
  // explicitly specified via `@` token. 
  //
  // @ (a, b, c)
  // is functionally equivalent with
  // @ (a or b or c)
  //
  // when modeling circuit that operates at clock-based functionality, we can
  // use keyword `posedge` or `negedge` to indicate that transition to
  // indicated signal executes the sequential logic.
  //
  // @ (posedge clk or negedge rst_n)
  always_ff @(posedge i_clk or negedge i_rst_n) begin: fifo_core
    if (!i_rst_n) begin
     w_idx <= 0; 
     r_idx <= 0; 
     o_level <= 0;
    end
    else begin

      if (!o_full && i_push) begin
        mem[w_idx] <= i_push_data;
        // if not full and there is a push request, push data to fifo
        o_level <= o_level + 1;
        // note than when dealing with literals, always make sure that the
        // prorper format prefix along with the size is explict, in this case
        // explicitly indiate to add a 1-bit "1".
        w_idx <= (w_idx == max_idx) ? 0 : (w_idx + 1);
      end

      if (!o_empty && i_pop) begin
        o_pop_data <= mem[r_idx];
        o_level <= o_level - 1;
        r_idx <= (r_idx == max_idx) ? 0 : (r_idx + 1);
      end

    end
  end: fifo_core

endmodule: fifo
