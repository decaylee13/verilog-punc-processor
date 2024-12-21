# verilog-punc-processor
A comprehensive implementation of a 16-bit processor based on the LC3 (Little Computer 3) instruction set architecture, designed for FPGA deployment. This project was developed to create a fully functional stored-program computer capable of executing complex programs.
Architecture Features
- 16-bit Word Size: All data and instructions are aligned 16-bit words
- Memory System:
    - 128-entry memory implementation (expandable)
    - Asynchronous reads and synchronous writes
    - Dual-port configuration with debug read capabilities
- Register File:
    - 8 general-purpose 16-bit registers (R0-R7)
    - Special handling for R7 in subroutine operations
    - Triple-port design with debug access
- Condition Codes:
    - Negative (N), Zero (Z), and Positive (P) flags
    - Automatically updated by arithmetic and load operations
- Program Counter:
    - 16-bit PC with automatic increment
    - Support for branching and jump operations

Instruction Set
- Implements a subset of the LC3 ISA including:
    - Arithmetic operations (ADD, AND)
    - Memory operations (LD, LDI, LDR, LEA, ST, STI, STR)
    - Control flow (BR, JMP, JSR, JSRR, RET)
    - System control (HALT)

Implementation Details
- Fetch-Decode-Execute cycle implementation
- Unpipelined design for simplicity and reliability
- Modular datapath construction with separate control unit
- Synthesizable Verilog code ready for FPGA deployment

Schematics
The processor's architecture is visualized in the datapath diagram below:
<img width="634" alt="Processor Datapath" src="https://github.com/user-attachments/assets/9c28aa39-3238-414a-81a3-d93e811fd656" />

The control signal states for different instructions are detailed in this table:
<img width="570" alt="Control Signal Table" src="https://github.com/user-attachments/assets/feaaca6f-dc1f-48e3-ac57-229320197a20" />

Below is an example of the signals running in Verilog. 
<img width="1461" alt="IMG_6774" src="https://github.com/user-attachments/assets/24da0b5e-088c-4a5f-aac3-6cc307e97db7" />
