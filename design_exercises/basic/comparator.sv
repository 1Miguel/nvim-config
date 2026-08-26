// **************************************************************************************
// @file comparator.sv
// @brief a single bit comparator
// **************************************************************************************

// below implements a gate-level single bit comparator
// we could've use logic since logic in systemverilog can also be continuously
// assigned, but we will use wire so it can be driven by multiple sources.
module comparator(
  input logic i_0,
  input logic i_1,
  output logic o_eq
);
  // note that this is a combinational circuit, the order of statement does
  // not matter since we're not designing a program, we're designing
  // a hardware circuit, the heirarchy is defined by the connection
  //
  // lets write a truth table for this 1-bit comparator
  //    i_0  |  i_1 | o_eq
  //    -------------------
  //     0   |   0  |  1   ---> ~i_0 & ~i_1
  //     0   |   1  |  0
  //     1   |   0  |  0
  //     1   |   1  |  1   ---> i_0 & i_1
  //
  // for a 1-bit comparator, we can write a boolean equation for its truth
  // table by summing each of the `minterms` for which the o_eq is TRUE
  // 
  // o_eq = (i_0 & i_1) | (~i_0 & ~i_1);
  //
  // this is what we call "sum-of-products" canonical form
  always_comb
    o_eq = (~i_0 & ~i_1) | (i_0 & i_1);

endmodule: comparator
