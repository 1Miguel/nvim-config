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

class SingletonTemplate #(type T, string type_name);

  static int count;
  static SingletonTemplate #(.T(T), type_name) inst;

  int id;

  function new();
    id = ++count;
  endfunction

  static function SingletonTemplate #(.T(T), type_name) get_instance();
    if (inst == null) begin
      $display("Create new singleton <%s>", type_name);
      inst = new();
    end
    else
      $display("Return singleton object <%s>", type_name);
    return inst;
  endfunction: get_instance

endclass: SingletonTemplate

class MyType1;
endclass : MyType1

typedef SingletonTemplate #(.T(MyType1), "MyType1") singleton_1_t;

class MyType2;
endclass : MyType2

typedef SingletonTemplate #(.T(MyType2), "MyType2") singleton_2_t;

module top();

  singleton_1_t s[4];
  singleton_2_t x[4];

  initial begin: init
    for (int i = 0; i < $size(s); i++)
      s[i] = singleton_1_t::get_instance();
    for (int i = 0; i < $size(s); i++)
      x[i] = singleton_2_t::get_instance();
  end: init

endmodule: top



