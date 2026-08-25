// **************************************************************************************
// @file top.sv
// @brief the top level module of the oop demonstration
//
// @usage you can execute this with verilator, example command is:
//
//    "verilator --binary --exe --timing -f files.f --top-module test_oop"
//
// then it will create an obj_dir, execute
//
//    "./obj_dir/Vtest_oop"
// 
// reference material: [System Verilog for verifcation: A guide to learning
//                  the testbench language feature by Chris Pear]
// **************************************************************************************

module test_oop();

  import oop_defs::*;

  // when we declare, we only create a `handle`, declaring does not mean
  // instantiation of object.
  BusTran b;

  initial begin: init


    // accessing object variable before and instance will raise a Null pointer
    // dereferenced exception
    // b.addr = 10;

    // but static variables can be accessed and initialised before any 'new()'
    // constructors are called
    b.count = 10;

    // calling new is similar to c malloc, we allocate memory to contain the
    // object, and pass the handle (pointer/memory) to the object handle.
    // note that new does more than allocation, it also initializes all the
    // variables/properties/attributes values.
    //    * all 2-state variable shall be initialised to '0'
    //    * all 4-state variable shall be initialised to 'X'
    //
    // but ofcourse, this might also vary depending on the compiler used. for
    // "verilator" vars are initialised to '0' even 4-state vars.
    b = new();
    b.display();

    // systemverilog classes has no concept of private vars, everything is
    // public vars
    $display("BusTran: <%h>(%d)", b.addr, b.data);
    
    // when will `b` be deallocated? in systemverilog, similar to other garbage
    // collected language (i.e python) counts the number of reference (ref
    // counting) an object has. if no other handle refers to the allocated
    // object, then it will be automatically be destroyed.
    //
    // so in this case, if we want to deallocate 'b', just set it to null
    b = null;

  end: init

endmodule: test_oop
