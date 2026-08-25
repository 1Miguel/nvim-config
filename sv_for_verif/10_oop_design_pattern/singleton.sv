// **************************************************************************************
// @file singleton.sv
// @brief simple exercise that demonstrate singleton pattern
// systemverilog
//
// @usage you can execute this with verilator, example command is:
//
//    "verilator --binary --exe --timing scope.sv"
//
// then it will create an obj_dir, execute
//
//    "./obj_dir/Vtop"
// 
// reference material: [System Verilog for verifcation: A guide to learning
//                  the testbench language feature by Chris Pear]
//
// **************************************************************************************

class Singleton;

  static int count;
  static Singleton inst;

  int id;

  // it is recommended to tag this method with "local" so it will not be
  // accessible, since we want to limit instantiation and force the use or the
  // application to use '::get_instance()' instead.
  //
  // but since this is a demonstration, we want to demonstrate that the count
  // will only increment once, since a singleton only have one instance.
  // 
  // example: local function new();
  function new();
    id = ++count;
  endfunction

  static function Singleton get_instance();
    if (inst == null)
      inst = new();
    return inst;
  endfunction: get_instance

endclass: Singleton

module top();

  Singleton s;
  Singleton x;
  Singleton y;

  initial begin: init
    s = Singleton::get_instance();
    x = Singleton::get_instance();
    y = Singleton::get_instance();

    $display("s=%p", s);
    $display("x=%p", x);
    $display("y=%p", y);
  end: init

endmodule: top


