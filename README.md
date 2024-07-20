Sure! Here’s the updated README file including the mention of using Verilator for simulation:

---

# RISC-V Five-Stage Pipelined Processor

## Overview
This repository contains the SystemVerilog implementation of a five-stage pipelined RISC-V processor supporting the RV32I base integer instruction set. The design includes the following pipeline stages: Fetch, Decode, Execute, Memory, and Write-back.

## Features
- **Instruction Set**: Supports the RV32I base integer instruction set.
- **Pipeline Stages**: Implements a five-stage pipeline.
- **Branch Prediction**: Includes basic branch prediction and control logic.
- **Memory**: Includes data and instruction memory modules.
- **Registers**: Implements a register file for storing and accessing general-purpose registers.
- **Control Unit**: Manages the control signals for each stage of the pipeline.

## Supported Instructions
The processor supports the following instructions:
- **Load Upper Immediate (LUI)**
- **Add Upper Immediate to PC (AUIPC)**
- **Jump and Link (JAL)**
- **Jump and Link Register (JALR)**
- **Branch Equal (BEQ)**
- **Branch Not Equal (BNE)**
- **Branch Less Than (BLT)**
- **Branch Greater Than or Equal (BGE)**
- **Load Byte (LB)**
- **Load Halfword (LH)**
- **Load Word (LW)**
- **Store Byte (SB)**
- **Store Halfword (SH)**
- **Store Word (SW)**
- **Add Immediate (ADDI)**
- **Set Less Than Immediate (SLTI)**
- **XOR Immediate (XORI)**
- **OR Immediate (ORI)**
- **AND Immediate (ANDI)**
- **Shift Left Logical Immediate (SLLI)**
- **Shift Right Logical Immediate (SRLI)**
- **Shift Right Arithmetic Immediate (SRAI)**
- **Add (ADD)**
- **Subtract (SUB)**
- **Shift Left Logical (SLL)**
- **Set Less Than (SLT)**
- **Set Less Than Unsigned (SLTU)**
- **XOR (XOR)**
- **Shift Right Logical (SRL)**
- **Shift Right Arithmetic (SRA)**
- **OR (OR)**
- **AND (AND)**

## File Structure
- `yarp_branch_control.sv`: Branch control logic for the processor.
- `yarp_control.sv`: Main control unit that generates control signals for various stages.
- `yarp_data_mem.sv`: Data memory module for load and store operations.
- `yarp_decoder.sv`: Instruction decoder that translates binary instructions into control signals.
- `yarp_execute.sv`: Execute stage where arithmetic and logic operations are performed.
- `yarp_instr_mem.sv`: Instruction memory module.
- `yarp_pkg.sv`: Package file containing common definitions and parameters.
- `yarp_regfile.sv`: Register file for storing general-purpose registers.
- `yarp_top.sv`: Top-level module integrating all components of the processor.

## Getting Started
### Prerequisites
- **Simulator**: You will need Verilator, a free and open-source SystemVerilog simulator, to run the simulations.
- **RISCV Toolchain**: A RISC-V toolchain to compile and generate binary files for testing.

### Running the Simulation
1. Clone the repository:
   ```sh
   git clone https://github.com/yourusername/riscv-processor.git
   cd riscv-processor
   ```
2. Install Verilator if you haven't already:
   ```sh
   sudo apt-get install verilator
   ```
3. Compile the SystemVerilog files with Verilator:
   ```sh
   verilator --cc yarp_top.sv --exe your_testbench.cpp
   make -j -C obj_dir/ -f Vyarp_top.mk Vyarp_top
   ```
4. Run the simulation:
   ```sh
   ./obj_dir/Vyarp_top
   ```

## Contributing
Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments
Special thanks to the authors and contributors of the RISC-V ISA for providing an open and extensible architecture.

---

Feel free to modify this README as per your specific project details and preferences.
