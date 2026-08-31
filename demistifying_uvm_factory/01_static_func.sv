class MyClass;
  
  function string my_name();
    return "my_name";
  endfunction

  static function string my_name();
    return "static my_name";
  endfunction

endclass: MyClass

module top();

  MyClass my_class;

  initial begin: init
    $display("my_class.static_count = %0d", my_class.my_name);
    $display("my_class.static_count = %d", my_class.my_static_name);
  end: init

endmodule: top
