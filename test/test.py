# SPDX-FileCopyrightText: © 2025 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

from tqv import TinyQV

import binascii

# When submitting your design, change this to the peripheral number
# in peripherals.v.  e.g. if your design is i_user_peri05, set this to 5.
# The peripheral number is not used by the test harness.
PERIPHERAL_NUM = 0

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 100 ns (10 MHz)
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())

    # Interact with your design's registers through this TinyQV class.
    # This will allow the same test to be run when your design is integrated
    # with TinyQV - the implementation of this class will be replaces with a
    # different version that uses Risc-V instructions instead of the SPI test
    # harness interface to read and write the registers.
    tqv = TinyQV(dut, PERIPHERAL_NUM)

    # Reset
    await tqv.reset()

    dut._log.info("Test project behavior")

    ## Configure peripheral
    # Step 1: reset peripheral via config
    await tqv.write_byte_reg(0x0,0x0)
    await tqv.write_byte_reg(0x4, 0b100) #RefIn RefOut high, XOR output
    await tqv.write_word_reg(0x10, 0x04C11DB7)
    
    crc = ~0x0 # init value
    # Enable peripheral input and start sending data
    await tqv.write_byte_reg(0x0,0xFF)
    data = b'123456789'
    for word in data:
        await tqv.write_byte_reg(0x8, int(word))
        await ClockCycles(dut.clk, 150)
    assert await tqv.read_word_reg(0xC) == 0x0376E6E7 # MPEG-2
    await tqv.write_byte_reg(0x0,0x00)

