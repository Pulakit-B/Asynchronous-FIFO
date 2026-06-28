# Asynchronous-FIFO
# Parameterized Asynchronous FIFO with Clock Domain Crossing (CDC)

## Overview
This repository contains a fully synthesizable, parameterized Asynchronous First-In-First-Out (FIFO) memory designed in Verilog. The core purpose of this design is to safely and reliably pass data between two independent, asynchronous clock domains without suffering from metastability or data corruption. 

This is not a simple behavioral model; it is a structural, hardware-accurate design that utilizes Gray code pointers and multi-stage synchronizers, making it suitable for modern ASIC and FPGA implementations.

## Key Architecture Features
* **Fully Parameterized:** The `DATA_WIDTH` and `DEPTH` can be easily scaled at the top level without altering the underlying logic.
* **Dual-Port Memory (SRAM):** Implemented using synchronous reads and writes, matching real-world hardware memory macro behaviors.
* **Clock Domain Crossing (CDC):** Uses robust 2-stage flip-flop synchronizers (`two_ff_synczr`) to safely pass pointers across clock boundaries.
* **Binary-to-Gray Logic:** Pointer synchronization uses Gray code conversion to ensure only one bit toggles at a time, eliminating the risk of sampling transitional garbage data across asynchronous clocks.
* **Pessimistic Flagging:** The `full_flag` and `empty_flag` are generated using look-ahead logic to act as absolute shields, preventing data overflow and phantom underflow reads.

## Module Hierarchy
The design is broken down into modular, highly readable components:
1. `FIFO_async_top` - The top-level wrapper binding all sub-modules.
2. `FIFO_mem` - The dual-port memory array.
3. `write_pointer` - Manages the binary write address, Gray code conversion, and `full` flag generation.
4. `read_pointer` - Manages the binary read address, Gray code conversion, and `empty` flag generation.
5. `two_ff_synczr` - The dual flip-flop synchronizer block.

## Verification & Testbench
The design includes a rigorous, race-condition-free testbench (`FIFO_async_tb.v`) designed to intentionally push the hardware to its edge cases. 

**Testbench Highlights:**
* **Independent Clock Generation:** Drives the write domain at a fast frequency (100 MHz) and the read domain at a slower frequency (50 MHz) to stress the synchronizers.
* **Overflow Attack (The Fill Test):** Deliberately attempts to write `DEPTH + 3` random payloads into the memory to prove the `full_flag` safely drops excess data.
* **Underflow Attack (The Drain Test):** Attempts to read `DEPTH + 3` times from an empty memory to prove the `empty_flag` prevents garbage data from propagating.
* **Strict Timing Compliance:** Utilizes strict Non-Blocking Assignments (`<=`) inside the Active Region/NBA Region to perfectly align with the Verilog Event Scheduler and eliminate simulator race conditions.

## Simulation
This project was simulated and verified using **Xilinx Vivado (XSim)**. 

To run the simulation locally:
1. Add all `.v` files to your project as Design Sources.
2. Add `FIFO_async_tb.v` as the Simulation Source.
3. Run Behavioral Simulation. 
4. *Tip:* Pull the internal `g_wrptr` and `g_rdptr` signals into the waveform viewer and change the radix to Unsigned Decimal to observe the Gray code synchronization in real-time.
