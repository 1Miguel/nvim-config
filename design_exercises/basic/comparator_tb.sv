// **************************************************************************************
// @file comparator_tb.sv
// @brief simple comparator testbench
// **************************************************************************************

module comparator_tb;

  // max value of a 2-bit logic, '1 means set all bits to 1
  localparam logic [1:0] MAX_I = '1;
  logic[1:0] i;
  logic o_eq;
  logic o_eq_expect;

  comparator dut(.i_0(i[0]), .i_1(i[1]), .o_eq(o_eq));

  initial begin;
    for (logic[2:0] j = 0; j <= 3'(MAX_I); j++) begin
      i = 2'(j);
      #1
      // what does &i and &~i means? &i means AND all bits of i, and &~ means
      // to inverse all bits then & all bits.
      //
      // in systemverilog, this is called `reduction` operator.
      assert (o_eq == ((&i) | &(~i)))
        else $fatal("output is expected to be true");
    end

    $finish;
  end

endmodule: comparator_tb

