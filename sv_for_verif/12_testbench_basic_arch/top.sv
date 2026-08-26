// **************************************************************************************
// @file top.sv
// @brief top level testbench.
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

// this is a simple exercise on how to create a testbench
//
// below are my notes about testbench. but there are a lot of things you will
// be missing out if you are just reading my notes below. i advice you read
//
// [System Verilog for verifcation: A guide to learning the testbench language
// feature by Chris Pear]
// 
// what is a testbench? a testbench contains multiple components. the basic
// building block of a testbench are:
//    1. Generator
//    2. Agent
//    3. Driver
//    4. Monitor
//    5. Checker
//    6. Scoreboard
//
// these components are clases modeled as `transactors`. and these components
// are instantiated and contained inside the `environment`.

`timescale 1ns/1ps

parameter int N_BITS = 32;

class Transaction #(parameter N);
  // a transaction classs contains generated test parametes the generator
  // generates and the driver drives to the dut
  rand logic [N-1:0] i_0;
  rand logic [N-1:0] i_1;
  // this is the output from the dut
  // ... here's a question, does monitor/checker requires a different
  // transaction type?
  logic eq;
endclass

class Generator;
  // this generator creates and randomize transaction packet and push the to
  // the driver, the driver will be the one responsible to drive the DUT
  mailbox mbx;
  Transaction #(.N(N_BITS)) tr;
 
  function new(mailbox mbx);
    this.mbx = mbx;
  endfunction

  task run(int n);
    repeat (n) begin
      // create new transaction
      this.tr = new();
      // randomize transaction parameters
      assert(this.tr.randomize());
      // put this transaction in mailbox
      mbx.put(this.tr)
      // delay
      #10
    end
  endtask

endclass: Generator

class Driver;
  // this driver waits for the generator to generate a transaction then drive
  // the dut based on the transaction parameters
  mailbox mbx;
  // transaction handle
  Transaction #(.N(N_BITS)) tr;
 
  function new(mailbox mbx);
    this.mbx = mbx;
  endfunction

  task run(int n);
    repeat (n) begin
      // wait until there is new generated transaction
      this.mbx.get(this.tr)
    end

endclass

class Checker;
  // monitor and checker
  mailbox mbx;
  // transaction handle
  Transaction #(.N(N_BITS)) tr;
 
  function new(mailbox mbx);
    this.mbx = mbx;
  endfunction

  task run(int n);
    repeat (n) begin
      // wait until there is new generated transaction
      this.mbx.get(this.tr)
    end

endclass

class Environment;

  // generator component
  Generator gen;
  // driver component
  Driver drv;
  // checker component, note that we merge monitor and checker
  Checker chk;
  // mailbox from generator to driver
  mailbox mbx_gen2drv:
  // mailbox from dut to monitor/checker
  mailbox mbx_dut2chk:

  task run();
    fork
      gen.run();
      drv.run();
      chk.run();
    join
  endtask;
endclass

module comparator_multi_bit_tb;

  localparam logic [N_BITS-1:0] MAX_I = '1;
  logic [N_BITS-1:0] i_0;
  logic [N_BITS-1:0] i_1;
  logic o_eq;

  comparator_multi_bit #(.N(N_BITS)) dut(.i_0(i_0), .i_1(i_1), .o_eq(o_eq));

  initial begin;
    $finish;
  end

endmodule: comparator_multi_bit_tb
