/**
 * @file register.sv
 * @brief a basic implementation of register
 *
 * In this exerice, we will also study different reset techniques
 * such as asynchronous and synchronous resets.
 */

module register_sync_reset #(
  
  // WIDTH is a System parameter.
  //
  // A system parameter is used to pass a constant to the 
  // module when it is instantiated. This is similar to C
  // #define where in constant is passed at compilation time.
  //
  // It is not considered under net or reg data types.
  //
  // NOTE:the parameter value can not be changed at run time.
  // SystemVerilog allows changing parameter values during
  // compilation time using the ‘defparam’ keyword.
  //
  // The parameter value can be updated in two ways
  //  1. Pass constant or define based value
  //  2. Use the ‘defparam’ keyword
  parameter int unsigned WIDTH = 32,

  // this is the default value of the register at reset
  parameter int unsigned DEFAULT = 0
) (
    input logic clk_i,
    input logic rst_i,
    input logic [WIDTH-1:0] data_i,
    output logic [WIDTH-1:0] data_o
  );

  logic [WIDTH-1:0] data;

  always @(posedge clk) begin 

    // this is a synchronous reset, the reset value is loaded
    // sync with the clk input
    if (!rst_i)
      data = DEFAULT;
    else begin
      data = data_i;
      data_o = data;
    end

  end

endmodule
