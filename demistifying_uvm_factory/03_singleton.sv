// **************************************************************************************
// @file singleton.sv
// @brief simple exercise that demonstrate singleton pattern
// systemverilog
// 
// reference material: [System Verilog for verifcation: A guide to learning
//                  the testbench language feature by Chris Pear]
//
// **************************************************************************************

class Singleton;

  static int count;
  static Singleton inst;

  int id;

  local function new();
    id = ++count;
  endfunction

  static function Singleton get_instance();
    if (inst == null) begin
      $display("Create new singleton");
      inst = new();
    end
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
