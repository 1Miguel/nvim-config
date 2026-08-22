# SystemVerilog Style Guide

This guide is a practical starting point for writing SystemVerilog that is easy
to read, review, simulate, synthesize, and reuse. It follows conventions that
are common in open-source and professional RTL projects. A project may
eventually choose stricter rules, but consistency is more important than any
single style.

## 1. General principles

- Prefer clear, boring RTL over clever or overly compact RTL.
- Make widths, signedness, reset behavior, and clock domains explicit.
- Keep one module focused on one well-defined responsibility.
- Write code that is warning-free under the project's simulator and linter.
- Do not rely on implicit nets, implicit widths, or tool-specific behavior.
- Keep formatting automated so reviews focus on behavior.

## 2. File and module organization

Use one primary module per file. Name the file after the module:

```text
rtl/
  counter.sv
  counter_tb.sv
```

Recommended file order:

1. Copyright or license header, if required by the project
2. Module declaration and parameters
3. Ports
4. Internal signals and local constants
5. Combinational logic
6. Sequential logic
7. Assertions or coverage
8. End-of-module comment, when useful

Use explicit ANSI-style ports:

```systemverilog
module counter #(
    parameter int unsigned WIDTH = 8
) (
    input  logic             clk_i,
    input  logic             rst_ni,
    input  logic             enable_i,
    output logic [WIDTH-1:0] count_o
);
```

Use suffixes consistently:

| Suffix | Meaning |
| --- | --- |
| `_i` | Input port |
| `_o` | Output port |
| `_io` | Bidirectional port |
| `_n` | Active-low signal |
| `_q` | Registered/state value |
| `_d` | Next-state value |

Do not combine suffixes in a confusing way. For example, use `reset_ni` for an
active-low reset input and `state_q` for registered state.

## 3. Naming

- Use `lower_snake_case` for signals, ports, modules, packages, functions, and
  tasks.
- Use `UPPER_SNAKE_CASE` for compile-time constants and macros.
- Use descriptive names such as `write_enable` instead of `we` unless the
  abbreviation is universally understood.
- Name clocks and resets clearly: `clk_i`, `rst_ni`, `scan_clk_i`.
- Use singular names for scalar signals and plural names for collections.
- Avoid names that differ only by capitalization.

Examples:

```systemverilog
localparam int unsigned FIFO_DEPTH = 16;

logic [7:0] data_d;
logic [7:0] data_q;
logic       empty;
```

## 4. Types, widths, and constants

- Use `logic` for most signals. Use `wire` only when a net specifically matters.
- Use `int unsigned` for parameters and loop variables when appropriate.
- Size literals when the width matters: `8'hA5`, `4'd3`, `1'b0`.
- Avoid unsized literals in width-sensitive expressions.
- Make signed arithmetic explicit with `signed` and sized operands.
- Prefer `localparam` for constants that must not be overridden.
- Use `typedef enum logic` for states and named choices.

```systemverilog
typedef enum logic [1:0] {
    IDLE,
    BUSY,
    DONE
} state_t;

state_t state_d, state_q;
```

Avoid implicit declarations by placing this at the top of source files:

```systemverilog
`default_nettype none
```

If a tool or integration requires the default to be restored, put this at the
end of the file:

```systemverilog
`default_nettype wire
```

## 5. Combinational logic

Use `always_comb` for combinational procedural logic and blocking assignments
(`=`) inside it:

```systemverilog
always_comb begin
    result = '0;

    if (enable_i) begin
        result = input_a + input_b;
    end
end
```

Always assign defaults before conditional assignments. This prevents inferred
latches and makes the intended behavior obvious.

For next-state logic, use a default copy and override only the transitions:

```systemverilog
always_comb begin
    state_d = state_q;

    case (state_q)
        IDLE: if (start_i) state_d = BUSY;
        BUSY: if (done_i)  state_d = DONE;
        DONE:              state_d = IDLE;
        default:           state_d = IDLE;
    endcase
end
```

Prefer `unique case` when exactly one item should match. Keep a `default`
branch unless the project's lint policy explicitly documents another choice.

## 6. Sequential logic

Use `always_ff` for flip-flops and nonblocking assignments (`<=`) inside it:

```systemverilog
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        count_q <= '0;
    end else begin
        count_q <= count_d;
    end
end
```

- Assign a register in one sequential block only.
- Keep clock and reset sensitivity lists consistent within a design.
- Document whether reset is synchronous or asynchronous.
- Do not use blocking assignments for clocked state.
- Do not gate clocks in RTL; use a clock-enable signal unless the technology
  flow provides a dedicated clock-gating cell.

## 7. Operators and expressions

- Use `==` and `!=` for ordinary 4-state comparisons when unknown values should
  be visible during simulation.
- Use `inside`, `case equality` (`===`), or case inequality (`!==`) only when
  their unknown-value behavior is intentional.
- Parenthesize mixed arithmetic and logical expressions.
- Avoid relying on operator precedence.
- Be careful with shifts, sign extension, truncation, and unsized constants.
- Use reduction operators deliberately: `|vector` is different from
  `vector != '0`.

## 8. Parameters and reusable modules

- Parameterize widths and capacities instead of duplicating modules.
- Constrain parameters when invalid values would create illegal ranges.
- Use `parameter int unsigned` for numeric configuration values.
- Keep parameter names and defaults documented.
- Avoid exposing implementation details as public parameters.

## 9. Assertions and verification

Assertions are useful documentation as well as checks. Put simple protocol and
invariant checks near the logic they describe:

```systemverilog
assert property (@(posedge clk_i) disable iff (!rst_ni)
    ready_o |-> valid_i);
```

Keep testbenches separate from synthesizable RTL. Use `_tb.sv` for testbench
files and make the top-level testbench name explicit in simulator commands.

## 10. Comments and documentation

- Explain intent, assumptions, clock-domain crossings, and non-obvious hardware
  behavior.
- Do not comment line-by-line syntax that the code already makes clear.
- Doxygen-style comments such as `/** ... */` and `///` can document modules,
  parameters, ports, signals, functions, and tasks. They are also readable
  when Doxygen is not configured to generate HTML or PDF documentation.
- Use `TODO(username):` for actionable unfinished work when the repository uses
  issue ownership.
- Update comments when behavior changes.
- Document units such as cycles, bytes, MHz, or nanoseconds.

See [`template.sv`](../template.sv) for a complete documented module example.

## 11. Common things to avoid

- `always @*` and `always @(...)` in new code when `always_comb` or `always_ff`
  expresses the intent better.
- Mixed blocking and nonblocking assignments in the same procedural block.
- Multiple drivers for a signal.
- Combinational feedback unless it is intentional and documented.
- Incomplete assignments that infer accidental latches.
- Integer loop counters used as hardware state.
- Wildcard cases (`casex` and usually `casez`) that can hide unknown values.
- Ignoring warnings without documenting why a warning is safe.

## 12. Recommended tools

### Verilator

Verilator is a fast open-source SystemVerilog simulator and lint tool. It is
excellent for compile-time checking, linting, and cycle-accurate simulation,
but it is **not a source formatter**.

Install on Debian or Ubuntu:

```bash
sudo apt update
sudo apt install verilator
```

Check a module without building a simulator:

```bash
verilator --lint-only --language 1800-2017 --Wall --Wno-fatal \
  -Irtl rtl/counter.sv
```

Lint a complete design with a selected top module:

```bash
verilator --lint-only --language 1800-2017 --Wall --Wno-fatal \
  --top-module counter \
  rtl/counter.sv rtl/package.sv
```

Warnings should be fixed rather than routinely suppressed. If a suppression is
necessary, keep it narrow and explain it in the project documentation.

### Verible

[Verible](https://github.com/chipsalliance/verible) is a widely used
open-source SystemVerilog formatter and linter. It is a good companion to
Verilator:

- `verible-verilog-format` formats source code.
- `verible-verilog-lint` checks style and common RTL problems.

After installing Verible, format one file:

```bash
verible-verilog-format --inplace rtl/counter.sv
```

Check formatting in CI without changing files:

```bash
verible-verilog-format --check rtl/*.sv
```

Lint files:

```bash
verible-verilog-lint rtl/*.sv
```

Format all SystemVerilog files under the repository:

```bash
find . -type f \( -name '*.sv' -o -name '*.svh' \) \
  -not -path './.git/*' \
  -exec verible-verilog-format --inplace {} +
```

For reproducible reviews, commit a formatter configuration if the project
needs non-default settings. Keep formatting and lint configuration in the
repository rather than relying on each developer's editor.

## 13. A beginner-friendly workflow

Run these commands from the repository root:

```bash
# 1. Format the files you changed.
verible-verilog-format --inplace path/to/module.sv

# 2. Check formatting.
verible-verilog-format --check path/to/module.sv

# 3. Run the style linter.
verible-verilog-lint path/to/module.sv

# 4. Run Verilator's RTL checks.
verilator --lint-only --language 1800-2017 --Wall --Wno-fatal \
  path/to/module.sv
```

Fix the first warning, run the checks again, and repeat. A clean result from
both Verible and Verilator is a useful baseline, but it does not replace a
testbench or functional verification.

## 14. Suggested project policy

For a small learning project, the following policy is a sensible default:

1. All new RTL uses `.sv`, `logic`, `always_comb`, and `always_ff`.
2. Every changed SystemVerilog file is formatted with Verible.
3. Verible lint and Verilator lint must pass before merging.
4. Warnings are treated as defects unless explicitly justified.
5. Module interfaces, reset polarity, clock domains, and units are documented.
