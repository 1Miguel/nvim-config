// **************************************************************************************
// @file oop_tb.sv
// @brief a simple test systemverilog that demonstrates oop
// **************************************************************************************

package oop_defs;

// if you are not familiar with oop terms:
//  1. Class - an encapsulation of data (variables) and
//     methods(routines/functions)
//  2. Object - instance of a class
//  3. Handle - a pointer to an object (aka reference). Its a container that
//     contains the address of an object. this is similar to pointer in c but
//     it can only point to single type (unlike c where you can pointer cast).
//  4. Method - procedural code that can manipulat vars contained in task or
//     functions.
//  5. Prototype - header of a routin that shows the name, type, and argument
//     list. the body of the routine contains the executed code.
//
//  note: that verilog traditionally prefer to use the term "variable" and
//  "routing" over "properties/attributes" and "methods".
class BusTran;

  // this is a static variable, in other languanges, this is called a 'class
  // variable'. this variable is shared and accessible to all instances/object
  // of this class. 
  static int count = 0;

  // class is a generic concept, it encapculates data and functions. when we
  // define a class in systemverilog, we define its attributes/properties and
  // methods.
  //
  // below are BusTran class attributes. NOTE that classes in systemverilog
  // has no concept of private and public properties. so the idea of a getter
  // and setter does not make sense. this is because those concepts only apply
  // to software development. keep in mind we are working on hardware test
  // simulation, there's a lot of downside in keeping some attributes private.
  int id;
  logic[31:0] addr;
  logic[31:0] crc;
  logic[31:0] data[8];

  // we've discuss in top.sv that the 'new()' routine is similar to C malloc, it
  // alloces memory of the instantiated object. but 'new' do more than that. we
  // can create new() routine within the class, this is what 'constructor' is
  // in systemverilog. implementing 'new()' also implements initialisation
  // routine to this class.
  function new(logic[31:0] addr=3, d=5);
    // what is 'this'? 'this' is similar to cpp 'this' and python 'self'. it
    // differentiate what is a local var (in a function) and what is an
    // attribute. notice that addr is an argument of this function and
    // therefore local to new(), but addr can also refer to the class
    // attribute. 'this' differentiates that.
    //
    // another reason to use this is because when accessing a variable,
    // systemverilog look it up from innerscope to parent scope to higher
    // scope until it finds a match.
    //
    // i would recommend always use 'this' when refering to class attribute,
    // be more explicit so readers can easily identify which are class vars
    // and which are not.
    this.id = count++;
    this.addr = addr;
    foreach(this.data[j])
      this.data[j] = d;
  endfunction

  // below are declarations of functions. note that there are two ways to
  // define a class method. one is inline inside the class definition and the
  // other is outside that classe similar to c++.
  function void display();
    $display("BusTran(%d): <%h>(%d)", id, this.addr, this.data);
  endfunction: display

  extern function void crc_calc();


endclass: BusTran

// this is an 'out-of-block' function declaration. we declare the function
// outside the class, the '::' is a scope operator which identifies that
// 'crc_calc()' is within the scope of 'BusTran' class.
function void BusTran::crc_calc();
  crc = addr ^ data.xor;
endfunction: crc_calc

endpackage: oop_defs
