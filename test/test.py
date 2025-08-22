import cocotb
from cocotb.clock import Clock
from cocotb.regression import TestFactory
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_fsm_processor(dut):
    dut._log.info("Starting FSM CPU test")

    # Start 50 MHz clock (20 ns period)
    clock = Clock(dut.clk, 20, units="ns")  # Adjusted for 50 MHz (20 ns period)
    cocotb.start_soon(clock.start())

    # Reset DUT
    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    await ClockCycles(dut.clk, 5)  # Wait for reset to propagate (5 cycles)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)  # Wait for 1 clock cycle after reset release

    # Program (instructions to be sent to the DUT)
    program = [
        0x41,
        0x42,
        0x81,
        0x82,
        0xC0,
        0x44,
        0x83,
        0xC0,
        0x00,
        0x00,
    ]

    for cycle, instr in enumerate(program):
        dut.ui_in.value = instr
        await ClockCycles(dut.clk, 1)  # Wait for the DUT to process the instruction
        dut._log.info(
            f"Cycle {cycle}: Sent instruction 0x{instr:02X} | "
            f"uo_out=0x{int(dut.uo_out.value):02X} | "
            f"uio_out=0x{int(dut.uio_out.value):02X} | "
            f"uio_oe=0x{int(dut.uio_oe.value):02X}"
        )

    # Additional wait cycles after program instructions to observe final results
    await ClockCycles(dut.clk, 50)  # Wait a few more cycles to allow for final outputs

    # Final output log
    dut._log.info(
        f"Final Output after test completion: "
        f"uo_out=0x{int(dut.uo_out.value):02X} | "
        f"uio_out=0x{int(dut.uio_out.value):02X} | "
        f"uio_oe=0x{int(dut.uio_oe.value):02X}"
    )

    dut._log.info("Simulation finished.")

    # Add a final wait cycle to prevent immediate stop after the last instruction
    await ClockCycles(dut.clk, 100)  # Extend simulation time by 100 more clock cycles

    # Make sure the simulation finishes after all instructions
    # If you have a "done" signal or an FSM signal that marks the end of the simulation, you can use that:
    await ClockCycles(dut.clk, 10)  # Wait 10 more cycles for clean exit

    dut._log.info("Test completed successfully.")

