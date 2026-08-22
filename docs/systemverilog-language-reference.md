# Datatypes
SystemVerilog datatypes and declaration and definition syntax is very similar to C. Below are some examples

```SystemVerilog

// logic is a 1-bit, 4-state variable (like the reg type)
// can be declared as any vector size
logic my_logic;
logic [32:0] my_logic;

// if you know c enum, you know sv enum
enum my_enum {
  entry_1, // = 0
  entry_2, // = 1
};


// struct declaration is very similar to c.
// collection of variables
struct my_struct {

};
```

## Module

Declarations and instantiations happens inside a module (between **module();** ... **endmodule**)

## Literal Assignment

```SystemVerilog
// parameter variables, by convention is always UPPERCASE
parameter SIZE = 64;
// logic vector size `SIZE`
logic [SIZE-1:0] data;
```

Let's say we want to assign all 1's to the logic data vector. One way to do it is:
```SystemVerilog
data = 64'hFFFFFFFFFFFFFFFF; // all ones
```

However, this is not scalable. If in the future SIZE has been changed to 32 or 128, this will fail. One way to make it scalable is by using complement/inversion:
```SystemVerilog
data = ~0; // all 1's
data = ~1; // all 0's
```

SystemVerilog provides a simpler syntax to fill a vector without having to specify a radix or binary, octal or hex. To fill each bit in a vector, we will use (') tick. Example below
```SystemVerilog
data = '0; // all zeroes
data = '1; // all ones
data = 'x; // unknown
data = 'z; // high-z
```

A vector can be filled with all zeroes, all X's(unknown), or all Zs (High Impedance).

## reg Type
The *reg* type would seem to imply a hardware *register*. But actually there is no correlation between using a *reg* variable and the hardware that will be inferred. It is in the context of usage that will determine if the hardware will be represented by a combinational or sequential circuit.
