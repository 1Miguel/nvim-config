/** 
 * @file builtin_datatypes.sv
 *
 * @brief a simple hello world example that demonstrate the
 *    basic structure of a systemverilog code.
 * 
 * @usage This file can be compiled via
 *    verilator --binary --exe --timing builtin_datatypes.sv
 *
 * Then to execute, run ./obj_dir/Vbuiltin_datatypes
 */

// all declarations and instantiations happens inside a module.
// all objects declared inside this module is local to only to
// this module. one way to think about this is this is a 
// declaration space.
//
// this module is named `test_datatypes`
//
// a module can also be instantiated inside another module. this
// enable a heirarchical design.
//
// (between **module();** ... **endmodule**)
//
// > Systemverilog for Design Chapter 2
module test_datatypes();

string my_name = "test_datatypes";

// overview on builtin datatypes
//
// verilog has two basic data types, variables (`reg`) and `nets` (net-type).
// `regs` and `nets` can hold four-state values: 0, 1, Z, X.
//    0: digital low
//    1: digital high
//    Z: high-impedance (high-z), this is used when a pin is floating
//       when driven to low (0) or high (1) overrides a Z.
//    X: represnets an unintialized value
// 
// we will call this datatypes as `four-state` datatypes.
// a `two-state` datatypes are types that can only holde 1 or 0.
//
// in systemverilog for simulation, using two-state improves simulation time
// compare to using four-state. this is because it reduces the number of
// possible values that a variable can hold.
//
// > Systemverilog for verification section Chapter 2 Datatypes
// > RTL modeling with Systemverilog for Simulation and Synthesis
//   chapter 3 Nets and Variables

// a `bit` defines that this variable is a two-state variable.
bit my_bit_1;
// this defines a 32-bit `vector` which can hold 2^2=4 state
bit [31:0] my_bit_2;

// `reg` keyword defines that a variable is a general purpose 4-state variable.
//
// in the context of RTL design, `reg` keyword would seem to imply a
// hardware register ...  but actually there is no correlation between
// using a `reg` variable and the hardware that will be inferred.
//
// It is in the context of usage that will determine if the hardware will
// be represented by a combinational or sequential circuit.
reg my_reg_1 = 1;

// this defines a four-state 32-bit vector
// since this is a 32-bit, we can also assign literal in the form hexadecimal
// integer. compare to other language wherein we can assign 0xdeadbeef, in
// systemverilog, we assign hexadecimal integer in format of `'{f}{literal}`
reg [31:0] my_reg_2 = 'hdeadbeef;

// by default, literal values with a base specified (i.e hex 'h) is treated
// as an unsigned value in operation and assignments. this default can be
// overriden by adding an s or S after the base specifier, example below
reg [16:0] my_reg_3 = 'sd9 + 'sh2f + 'sb1010;


// `logic` is equivalent to `reg`. a `logic` also defines that this variable
// is a four-state variable.
//
// NOTE: `logic` is preferred over `reg`, so from this point onward we will
// use `logic` than reg
logic my_logic_1;
// this defines a 32-bit logic `vector`
logic [31:0] my_logic_2;
// we will use this for $isunknown demo below
logic [3:0] my_logic_3 = 4'b10x0;

// NOTE: there is one limitation to `reg` and `logic`, it cannot be driven
// by multiple drivers, such as when you are modeling a bidirectional bus
// in cases like this, we will use `net-type` such as wire, we will
// demonstrate that in a different file

// Systemverilog also have other two-state datatypes which improves
// simulator performance and reduce memory, this types are
bit b;         // single bit
bit[31:0] b32; // 32-bit unsigned integer
int i32;       // 32-bit signed integer
byte b8;       // 8-bit unsigned integer
shortint si;   // 16-bit integer
longint li;    // 64-bit signed integer

initial begin: init

  $display("******************************");
  $display("Hello world from: %s", my_name);
  $display("******************************");

  my_bit_2 = 2;
  // each bit in a vector` can be accessed like an array
  $display("my_bit_2 = 0x%x", my_bit_2);
  $display("my_bit_2[0] = %d", my_bit_2[0]);
  $display("my_bit_2[1] = %d", my_bit_2[1]);

  // print as octal
  $display("my_reg_1=0o%o", my_reg_1);
  // print as hex
  $display("my_reg_2=0x%x", my_reg_2);
  // print as decimal
  $display("my_reg_3=%d", my_reg_3);

  // here's a note to keep in mind, we have to be careful when connecting
  // two-state variables to DUT, especially to its output ports.
  //
  // if the DUT ports tries to drive an X or a Z, this values could be
  // converted to two-states unknowingly to the testbench. to prevent this
  // you can use $isunknown operator that returns 1 if any bit of the
  // expression is either an `X` or a `Z`.
  //
  // NOTE: this will not work with verilator since verilator is a 2-state
  // simulator and cannot handle 4-state.
  my_logic_3 = 4'b10x1;
  $display("is 4-state value detected: (%b) %d?",
    my_logic_3, $isunknown(my_logic_3));

  $display("******************************");
  $display("end of test: %s", my_name);
  $display("******************************");

end: init

// marks the end of a module, this is called an `end statement`
// note that the `: test_hello_world` is what we call a label
// which helps the reader of the code to match the end of end
// of a procedural blocks
//
// other end statements are endtask, endfunction etc.
endmodule: test_datatypes
