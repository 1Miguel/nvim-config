# Running yosys

To run yosys, it is advisable to use the openroad/orfs. Assuming you already have **docker** installed, pull the image using command below:
```bash
docker pull openroad/orfs
```

Then run docker image with the current directory mounted.
```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  -w /workspace \
  openroad/orfs
```

docker options meaning:
  * docker run → start a container
  * --rm → delete container when done
  * -it → give me an interactive shell
  * -v "$PWD:/workspace" → make my current project available inside Docker
  * -w /workspace → start inside my project directory openroad/orfs → use the OpenROAD Flow Scripts image

# Yosys Commands

Refer to: [Yosys Getting Started Guide](https://yosyshq.readthedocs.io/projects/yosys/en/stable/getting_started/example_synth.html)
1. Load the design by running, this will immediately open interactive yosys shell, sv files will be parsed an converted to AST.
```bash
yosys rtl/*.sv
```

you can also just run yosys then use **read_verilog** command to parse sv files.
```bash
root@0:/workspace# yosys

yosys> read_verilog ./rtl/*.sv
```

>[!NOTE]
>./rtl/*sv is relative to workspace path, which is in this case, the directory ($PWD) we mounted at docker run (-v $PWD:/workspace)

2. declare the topmodule with [hierarchy](https://yosyshq.readthedocs.io/projects/yosys/en/stable/cmd/index_passes_hierarchy.html#cmd-hierarchy). The top module in this case is the [**uart_top**](./rtl/uart_top.sv) module.
```bash
yosys> heirarcy -top uart_top
```

> [!Note]
> [hierarchy](https://yosyshq.readthedocs.io/projects/yosys/en/stable/cmd/index_passes_hierarchy.html#cmd-hierarchy) should always be the first command after the design has been read. By specifying the top module, hierarchy will also set the (*top*) attribute on it. This is used by other commands that need to know which module is the top.

3. To generate schematic, use [show](https://yosyshq.readthedocs.io/projects/yosys/en/stable/cmd/index_passes_status.html#cmd-show) command.
```bash
show -prefix uart -format dot
```

options meaning:
  * -format <format>: format of the graphics file. some valid options are: 'svg', 'ps', 'dot'.
  * -prefix <prefix>: name of the file, i.e -prefix my_graph will generate 'my_graph.<format>' (format is from *-format* option).

Use dot if you want to view hierarchy of multiple modules. svg only works on one module.

3.1 If dot was used as format, you can convert .dot to .png to be able to view as image. Use command:
``` bash
dot -Tpng <prefix>.<format> -o <prefix>.png
```
Then to view the image
``` bash
xdg-open <prefix>.png
```

4. Run proc which will translate processes to netlists.
```bash
yosys> proc
yosys> opt
yosys> fsm
yosys> opt
yosys> memory
yosys> opt
```

5. 
