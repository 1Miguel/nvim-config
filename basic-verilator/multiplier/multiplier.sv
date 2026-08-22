/**
 * @file template.sv
 * @brief A simple multiplier based on the book
 *  Digital Design by Harris & Harris.
 *
 * @tutorial
 * To compile this code (with verilator) use command
 *  verilator --cc multiplier.sv
 *
 * Once you execute this command, it will generate a `obj_dir`
 * directory. Inside you will find the verilated (cpp) output.
 * since verilator compile sv code to cpp code.
 */

/**
 * @brief A simple multipler circuit.
 */
module multiplier #(
  /**
   * WIDTH is a System parameter.
   *
   * A system parameter is used to pass a constant to the 
   * module when it is instantiated. This is similar to C
   * #define where in constant is passed at compilation time.
   *
   * It is not considered under net or reg data types.
   *
   * NOTE:the parameter value can not be changed at run time.
   * SystemVerilog allows changing parameter values during
   * compilation time using the ‘defparam’ keyword.
   *
   * The parameter value can be updated in two ways
   *  1. Pass constant or define based value
   *  2. Use the ‘defparam’ keyword
   */
  parameter int unsigned WIDTH = 32
) (
    input logic [WIDTH:0] a_i, b_i,
    output logic [WIDTH:0] c_o
  );
  assign c_o = a_i * b_i;
endmodule
