/** 
 * @file hello_world.sv
 *
 * @brief a simple hello world example that demonstrate the
 *    basic structure of a systemverilog code.
 * 
 * @usage This file can be compiled via
 *    verilator --binary --exe --timing hello_world.sv
 *
 * Then to execute, run ./obj_dir/Vhello_world
 */

// all declarations and instantiations happens inside a module.
// all objects declared inside this module is local to only to
// this module. one way to think about this is this is a 
// declaration space.
//
// this module is named `test_hello_world`
//
// a module can also be instantiated inside another module. this
// enable a heirarchical design.
//
// (between **module();** ... **endmodule**)
//
// > Systemverilog for Design Chapter 2
module test_hello_world();

// declares a string variable `s`.
//
// using `reg` type to store string of characters is painful.
// string type in system verilog provides a convenient datatype
// to hold/store variable length string of characters.
//
// systemverilog also provides string manipulation built-in methods.
// but we will discuss that later.
string my_name = "test_hello_world";

// all executable code runs within a module is contained inside
// a `procedural block`.
//
// below is an initial procedural block. all code that execute
// inide this procedural block are initialization procedures.
// this is similar to python's __init__.
//
// all routines within the initial block runs only once
//
// > Systemverilog for verification section 3.2 Procedural Statement
// > RTL modeling with Systemverilog for Simulation and Synthesis
//   section 2.1 Modules and procedural blocks
initial begin: init

  // $display is a system function that is akin to C printf.
  // $display supports string formatting
  //
  // notice the `$` sign prefix? in systemverilog, `${name}` are what
  // you call system functions. system functions are built-in language
  // features. we can dedicate another code to emphasize this.
  $display("******************************");
  $display("Hello world from: %s", my_name);
  $display("******************************");

end: init

// marks the end of a module, this is called an `end statement`
// note that the `: test_hello_world` is what we call a label
// which helps the reader of the code to match the end of end
// of a procedural blocks
//
// other end statements are endtask, endfunction etc.
endmodule: test_hello_world
