// **************************************************************************************
// @file fifo_tb.sv
// @brief simple comparator testbench
// **************************************************************************************

// this tests the comparator in multi-bit mode. we will generate random
// integers and compare them, we expect that it when two random numbers are
// equal, the comparator block must produce true, else false
//
// a multi-bit comparator is similar to xor'ing two numbers then inverse the
// result, i.e
//    a = 1'b1001
//    b = 1'b0101
//    x = 1'b1100
//   ~x = 1'b0011 --> only last 2-bits are equal
//
// so we will use this expression as our reference model
//
// I know this is a simple circuit to test, but we will do this over the top,
// we will generate a couple of test components
//    > the generator generates random inputs
//    > driver drives the dut
//    > the transaction is the message that generator passes to the driver
//    > the checker that checks if the output of the dut is valid
//
// the generator communicates to the driver via mailbox and the generator and
// driver communicates to the checker via mailbox as well.
//
// if you have a software background like me, testbench architecture utilizes
// message passing, and is a concept no different from what software
// engineering uses i.e microservices, event driven patterns etc.

//`timescale 1ns/1ps

// sets the number of generated transaction
parameter int N_TRANS = 32;

// sets the bit size of the comparator DUT
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

  function string name();
    return "Transaction";
  endfunction

  function string repr();
    // a custom string representation of transaction inspired by python's repr,
    // this can be use for nice representation when doing a display
    // i.e $display(tr.repr());
    return $sformatf("%s<i0=%0h, i1=%0h>", this.name(), this.i_0, this.i_1);
  endfunction

  function display();
    $display(this.repr());
  endfunction
endclass

// a transaction maibox type
// we typedef so we done need to keep on typing parametrize transaction
typedef mailbox #(Transaction #(.N(N_BITS))) mailbox_tr_t ;

class Generator;
  // this generator creates and randomize transaction packet and push the to
  // the driver, the driver will be the one responsible to drive the DUT
  mailbox_tr_t mbx;
  Transaction #(.N(N_BITS)) tr;
 
  function new(mailbox_tr_t mbx);
    this.mbx = mbx;
  endfunction

  task run(int n);
    repeat (n) begin
      // delay
      #10
      // create new transaction
      this.tr = new();
      // randomize transaction parameters
      assert(this.tr.randomize() != 0);
      // put this transaction in mailbox
      $display("generator: %s", tr.repr());
      mbx.put(this.tr);
    end
  endtask

endclass: Generator

class Driver;
  // this driver waits for the generator to generate a transaction then drive
  // the dut based on the transaction parameters
  mailbox_tr_t mbx;
  // transaction handle
  Transaction #(.N(N_BITS)) tr;
 
  function new(mailbox_tr_t mbx);
    this.mbx = mbx;
  endfunction

  task run(int n);
    repeat (n) begin
      // wait until there is new generated transaction
      this.mbx.get(this.tr);
      $display("driver: %s", tr.repr());
    end
  endtask

endclass

class Checker;
  // monitor and checker
  mailbox_tr_t mbx;
  // transaction handle
  Transaction #(.N(N_BITS)) tr;
 
  function new(mailbox_tr_t mbx);
    this.mbx = mbx;
  endfunction

  task run(int n);
    repeat (n) begin
      // wait until there is new generated transaction
      this.mbx.get(this.tr);
      $display("checker: %s", tr.repr());
    end
  endtask

endclass

class Environment;

  // generator component
  Generator gen;
  // driver component
  Driver drv;
  // checker component, note that we merge monitor and checker
  Checker chk;
  // mailbox from generator to driver
  mailbox_tr_t mbx_gen2drv;
  // mailbox from dut to monitor/checker
  mailbox_tr_t mbx_dut2chk;

  task run();
    fork
      gen.run(N_TRANS);
      drv.run(N_TRANS);
      chk.run(N_TRANS);
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
