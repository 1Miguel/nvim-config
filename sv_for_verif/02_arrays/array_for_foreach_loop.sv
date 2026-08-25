/**
  * @file array_for_foreach_loop.sv
  * @brief a simple example of for and for loop.
  *
  * to run this in verilator, use command
  *   > verilator --binary --exe --timing array_for_foreach_loop.sv
  *
  * to execute, run ./obj_dir/Varray_for_foreach_loop
  */

module array_for_foreach();

initial begin


  // we can declare array in two ways, one to provide an upper
  // and lower limits, below is an example of declaring 8-bit
  // array with length of 5.
  //
  // [0:4] means array indices ranges from 0 through 4.
  bit[7:0] src[0:4];

  // another way is a shortcut, similar to C, see `dest` example
  // below
  // 
  // Systemverilog stores each elements on a longword (32-bit)
  // boundary. so a byte, shortint int etc are all stored in a single
  // longword. so for the declaration below of 8-bit dest:
  //
  //         +----------+---------+---------+---------+
  //         |  byte[3] | byte[2] | byte[1] | byte[0] |
  //         +----------+---------+---------+---------+
  // dest[0] |         Unused Space         |  used   |
  //         +----------+---------+---------+---------+
  //
  // !NOTE: we call this as `unpacked` array
  //
  // > SystemVerilog for Verification Chapter 2
  bit[7:0] dest[5];

  // this is another way to declare an array but in this case
  // this is what we call a `packed` array.
  //
  // in a packed (bit) array, the dimension size aka array size is included
  // in the type, i.e below is an example of a 4 byte array but in this
  // cased this is a packed array
  //
  //   7       0 7       0 7       0 7       0
  //  +---------+-0-------+---------+---------+
  //  |  b32[3] |  b32[2] |  b32[1] |  b32[0] |
  //  +---------+---------+---------+---------+
  //
  //  Unlike in packed array to which all elements are stored in
  //  32-bit aligned boundary, a packed array utilizes only the space
  //  indicated by the type.
  bit[3:0][7:0] b32;

  // in this exercise, use for loop to iterate and initialise
  // each element of src array
  $display("for loop start");
  for (int i = 0; i < $size(src); i++) begin
    $display("src[%d] = %d", i, i[7:0]);
    // int i is 32-bit but src is only 8-bit, whit will potentially cause
    // a lint error (but systemverilog allows this). to resolve this we
    // can do a part select
    src[i] = i[7:0];
  end

  // foreach has a very simple syntax, when using foreach, inside you
  // specify array variable name and square bracket with inside an
  // index variable that contains incrementing index as the array
  // is iterated.
  $display("foreach start");
  foreach (dest[j]) begin
    $display("dest[%d] = %d", j, src[j] * 2);
    dest[j] = src[j] * 2;
  end

  // we can aggregate compare the two arrays aggrate simply means
  // compare each alement of both array if they are equal
  $display("src %s dest", (src==dest) ?  "==" : "!=");

  // we can also do an aggregate copy, each element will be copied
  // from dest to src
  dest = src;
  $display("src %s dest", (src==dest) ? "==" : "!=");

  // we can also do a slicing of array so we can copy or compare slices
  $display("src %s dest", (src[1:4]==dest[1:4]) ? "==" : "!=");

  // as a C programmer, C has this feature that a uint32_t can be accessed
  // as uint8_t[4] by pointer casting. an example to this feature is
  //    uint32_t x = 0xdeadbeef;
  //    uint8_t *p = (uint8_t *)&x;
  //    printf("0x%x", p[0]); // 0xef
  //    printf("0x%x", p[1]); // 0xbe
  //    printf("0x%x", p[2]); // 0xad
  //    printf("0x%x", p[3]); // 0xde
  //
  // systemverilog does not have a pointer neither have pointer casting but
  // systemverilog has a similar concept to this with packed array. below
  // is an example of the similar C example above

  b32 = 32'hdeadbeef;
  foreach(b32[j])
    $display("b32[%d]: 0x%x", j, b32[j]);

  $display("b32[%d] bit %d: ", 1, 2, b32[1][2]);
  
end

endmodule: array_for_foreach
