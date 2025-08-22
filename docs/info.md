<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

# Finite State Machine (FSM)

## Credits
- Department of CSE

## How it Works
This design implements a **Finite State Machine (FSM)** with the following components:

### States:
- `State 0`: Initial state
- `State 1`: Intermediate state
- `State 2`: Intermediate state
- `State 3`: Final state

### Inputs:
- `clk` (clock)
- `rst_n` (active-low reset)
- `input_signal` (controls state transitions)
- `enable` (enables transitions)

### Outputs:
- `state_out` (current state)
- `output_signal` (based on state)

### State Transitions:
Transitions occur on the rising edge of `clk` when `enable` is active. Reset (`rst_n`) brings the FSM back to `State 0`.

## Reset Behavior
- When `rst_n` is low, FSM resets to `State 0`.

## How to Test
Use the provided **Verilog testbench** (`tb_fsm.v`) or **Cocotb Python test** (`test_fsm.py`).

### Example Test Scenarios:
| Initial State | input_signal | Expected Output Signal | Final State |
|---------------|--------------|------------------------|-------------|
| State 0       | 1            | 0                      | State 1     |
| State 1       | 0            | 0                      | State 2     |
| State 2       | 1            | 1                      | State 3     |
| State 3       | 0            | 0                      | State 0     |

## External Hardware
The FSM can be used in larger systems to control operations based on state transitions.

