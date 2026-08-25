// **************************************************************************************
// @file top.sv
// @brief the top level module of the oop demonstration
//
// @usage you can execute this with verilator, example command is:
//
//    "verilator --binary --exe --timing scope.sv"
//
// then it will create an obj_dir, execute
//
//    "./obj_dir/Vtest_oop"
// 
// reference material: [System Verilog for verifcation: A guide to learning
//                  the testbench language feature by Chris Pear]
//
// UPDATE: ok while trying this exercise, apparently verilator does not
// support &root system operator.
// **************************************************************************************

// lets demonstrate scope resolution, outside, we define count. we should be
// able to refer to this via $root.count, since count in within the scope of
// the root or rather 'global scope'.
int count;

class BusTran;

  // this count is within the 'class scope'
  int count;

endclass

module test_oop();

  // this count is within the 'module scope'
  int count;

  // when we declare, we only create a `handle`, declaring does not mean
  // instantiation of object.
  BusTran b;

  initial begin: init
    b = new();
    // this count is within the '(procedural) block scope'
    // int count = $root.count;
    // systemverilog classes has no concept of private vars, everything is
    // public vars
    $display("global count: ", $root.count);
  end: init

endmodule: test_oop

