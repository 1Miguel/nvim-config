// **************************************************************************************
// @file 00_static.sv
// @brief simple exercise that demonstrate class static vars and functions.
// systemverilog
// 
// reference material: [System Verilog for verifcation: A guide to learning
//                  the testbench language feature by Chris Pear]
//
// **************************************************************************************

class MyClass;

  static int static_count;
  int my_count;

  function string my_name();
    return "my_name";
  endfunction

  static function string my_static_name();
    return "static my_name";
  endfunction

endclass: MyClass

module top();

  MyClass my_class;

  initial begin: init

    $display("my_class.my_static_name = %0d", my_class.my_static_name());
    $display("my_class.my_name = %0d", my_class.my_name());
    my_class.static_count++;
    $display("my_class.static_count = %0d", my_class.static_count);
    my_class.my_count++;
    $display("my_class.static_count = %d", my_class.my_count);
  end: init

endmodule: top



