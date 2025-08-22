import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_fsm_processor(dut):
    dut._log.info("Starting FSM CPU test")

    # Start 100MHz clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset DUT
    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.ui_in_reg.value = 0
    dut.uio_in_reg.value = 0

    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    program = [
        0x41, 0x42, 0x81, 0x82, 0xC0, 0x44, 0x83, 0xC0, 0x00, 0x00
    ]

    for cycle, instr in enumerate(program):
        dut.ui_in_reg.value = instr
        dut.uio_in_reg.value = instr  # Drive uio_in as well
        await ClockCycles(dut.clk, 1)
        dut._log.info(
            f"Cycle {cycle}: Sent instruction 0x{instr:02X} | "
            f"uo_out=0x{int(dut.uo_out.value):02X} | "
            f"acc_debug=0x{int(dut.acc_debug.value):02X} | "
            f"state_debug=0x{int(dut.state_debug.value):02X}"
        )

    # Additional wait cycles after program instructions to observe final results
    await ClockCycles(dut.clk, 50)  # Wait for 50 more cycles

    # Log final output after extra wait cycles
    dut._log.info(
        f"Final Output after test completion: "
        f"uo_out=0x{int(dut.uo_out.value):02X} | "
        f"acc_debug=0x{int(dut.acc_debug.value):02X} | "
        f"state_debug=0x{int(dut.state_debug.value):02X}"
    )

    dut._log.info(f"Simulation finished. Final uo_out: 0x{int(dut.uo_out.value):02X}")

    # Graceful test completion
    #assert dut.uo_out == 0x4A  # Example assertion, modify according to expected value

