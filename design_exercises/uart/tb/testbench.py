import logging
import random

from typing import TYPE_CHECKING

import cocotb

from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

if TYPE_CHECKING:
    from cocotb.handle import SimHandle


log = logging.getLogger("testbench")
log.setLevel(logging.DEBUG)


@cocotb.test()
async def test_uart_tx(dut: "SimHandle"):
    """Basic Uart Transmit Test."""
    # create a 10ns period clock
    clock = Clock(dut.clk_i, 1, unit="ns")
    # assert the reset signal
    dut.rst_n_i.value = 0
    # start the clock
    cocotb.start_soon(clock.start())
    # let clock run for a few cycles
    await ClockCycles(dut.clk_i, 5)
    # check reset states
    assert dut.tx_o.value == 1

    # deassert the reset signal
    dut.rst_n_i.value = 1

    # let clock run for a few more cycles
    # so we can observe the div clock
    await ClockCycles(dut.clk_i, 32)

    assert dut.tx_o.value == 1
    assert dut.tx_busy_o.value == 0
    assert dut.tx_done_o.value == 0

    # transmit data
    test_data = random.randint(0, 255)
    test_data = int("0b00101101", 2)
    log.debug("generate random data: %s", f"0b{test_data:8b}")

    # setup uart config
    #   > no parity
    #   > 1 stop bit
    dut.parity_en_i.value = 0
    dut.parity_i.value = 0
    dut.num_stop_bit_i.value = 0
    # load tx data
    dut.tx_data_i.value = test_data
    # start tx
    dut.tx_start_i.value = 1
    await ClockCycles(dut.clk_i, 1)
    dut.tx_start_i.value = 0

    # let clock run so we can observe the data output
    # max total number of bits:
    #   1 start bit + 8 data bits + 1 parity bit + 2 stop bits
    #   = 12 bits
    #   total_cycles = 12 bits * 16 div * 16 = 4096
    # so will probably run at 192 so its power of 2
    await ClockCycles(dut.clk_i, 4096)
