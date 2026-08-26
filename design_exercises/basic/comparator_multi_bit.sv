// **************************************************************************************
// @file comparator.sv
// @brief a single bit comparator
// **************************************************************************************

// below implements a gate-level single bit comparator
// we could've use logic since logic in systemverilog can also be continuously
// assigned, but we will use wire so it can be driven by multiple sources.
module comparator_multi_bit #(
  parameter int N=32
)
(
  input logic [N-1:0] i_0,
  input logic [N-1:0] i_1,
  output logic o_eq
);
  logic [N-1:0] eq;

  // generate block means we generate this hardware circuit N number of times.
  generate
    for (genvar i = 0; i < N; i++) begin : gen_comp
      comparator c(i_0[i], i_1[i], eq[i]);
    end
  endgenerate

  // use & `reduction` operator, if all bits are equal then AND of all bits
  // must be equal to `1`
  // by the way, i had a problem wherein i forgot to put 'assign' and it
  // causes a compilation error. below expression is a `continuous` assignment
  // which therefore requires `assign` keyword
  // without assign requires the expression to be inside a `procedural` block
  // aka always_* block.
  assign o_eq = & eq;

endmodule: comparator_multi_bit

