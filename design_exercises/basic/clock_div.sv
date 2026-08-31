// **************************************************************************************
// @file clock_div.sv
// @brief design implementation simple clock divider
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

// simple clock divider using counter, below is a visualization of div2
//       0         1         0         1         0         1
//  i ___|¯¯¯¯¯|___|¯¯¯¯¯|___|¯¯¯¯¯|___|¯¯¯¯¯|___|¯¯¯¯¯|___|¯¯¯¯¯|
//  o ___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|___|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|

`timescale 1ns/1ps

module clock_div #(parameter int N=8)(
  input logic i_clk,
  input logic i_rst_n,
  input logic [N-1:0] i_div,
  output logic o_clk,
);
  input logic [N-1:0] count;

  assign o_clk = (count == (i_div - 1));

  always_ff @(posedge i_clk) begin
    if (!i_rst_n)
      count <= '0;
    else
      count <= (count < i_div) ? (count + 1) : 0;
  end

