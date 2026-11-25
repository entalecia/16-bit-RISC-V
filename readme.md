# 16-Bit Single-Cycle RISC Processor (Verilog)

A custom **16-bit single-cycle Harvard-architecture RISC processor** designed, implemented, and verified from scratch in Verilog HDL. Inspired by the classic single-cycle datapath in Patterson & Hennessy's *Computer Organization and Design (RISC-V Edition)*, this core supports arithmetic, logical operations, memory load/store, conditional branching, unconditional jumping, and a dedicated hardware `HLT` state.

---

## Architecture & Datapath

![16-Bit Single-Cycle RISC Processor Architecture](architecture.png)

### Key Architectural Specifications
* **Datapath Width:** 16-bit word-addressed single-cycle execution (1 instruction per clock cycle)
* **Memory Architecture:** Harvard (separate Instruction Memory and Data Memory)
* **Register File:** 8 general-purpose 16-bit registers (`R0`–`R7`), with two combinational read ports and one synchronous write port (`R0` initialized to `0` on reset and reserved as a zero constant)
* **Instruction Memory (ROM):** 64 × 16-bit words, combinational read, dynamically loaded from external `.mem` binary files via `$readmemb`
* **Data Memory (RAM):** 64 × 16-bit words, synchronous write and combinational read
* **Branch & Store Register Multiplexing:** An OR gate (`Branch | MemWrite`) dynamically routes `Instruction[11:9]` to `Read Register 2` for `BEQ` and `SW` instructions, while R-type instructions read `Instruction[5:3]`
* **Hardware Halt (`HLT`):** Dedicated opcode (`4'b1111`) that locks all write-enable signals (`RegWrite = 0`, `MemWrite = 0`), freezes the Program Counter (`PC`) via a feedback MUX, and asserts a top-level `halted` output pin for self-terminating testbenches

---

## Instruction Set Architecture (ISA)

All instructions are fixed-width **16-bit** words organized into three formats:

| Format | `[15:12]` (4 bits) | `[11:9]` (3 bits) | `[8:6]` (3 bits) | `[5:3]` (3 bits) | `[2:0]` (3 bits) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **R-Type** | `Opcode` | `Rd` | `Rs1` | `Rs2` | `000` (Unused) |
| **I-Type** | `Opcode` | `Rd` / `Rs2` | `Rs1` | `Immediate [5:0]` (6-bit signed) | ← |
| **J-Type** | `Opcode` | `Target Address [11:0]` (12-bit) | ← | ← | ← |

### Opcode Table

| Opcode | Mnemonic | Type | Operation / Behavior |
| :---: | :---: | :---: | :--- |
| `0000` | `NOP` | — | No operation (`PC = PC + 1`) |
| `0001` | `ADD` | R | `Rd = Rs1 + Rs2` |
| `0010` | `SUB` | R | `Rd = Rs1 - Rs2` |
| `0011` | `AND` | R | `Rd = Rs1 & Rs2` |
| `0100` | `OR` | R | `Rd = Rs1 \| Rs2` |
| `0101` | `SLT` | R | `Rd = (Rs1 < Rs2) ? 16'd1 : 16'd0` |
| `0110` | `ADDI` | I | `Rd = Rs1 + SignExt(imm6)` |
| `0111` | `LW` | I | `Rd = DMEM[Rs1 + SignExt(imm6)]` |
| `1000` | `SW` | I | `DMEM[Rs1 + SignExt(imm6)] = Rs2` |
| `1001` | `BEQ` | I | `if (Rs1 == Rs2) PC = PC + SignExt(imm6)` |
| `1010` | `JMP` | J | `PC = {PC[15:12], addr12}` |
| `1111` | `HLT` | — | Freeze `PC` (`PC_next = PC`) and assert `halted = 1` |

### Control Signals Summary

| Signal | Width | Function |
| :--- | :---: | :--- |
| `Halt` | 1-bit | Freezes `PC` at its current address and asserts the top-level `halted` flag |
| `Jump` | 1-bit | Selects `{PC[15:12], Instruction[11:0]}` as the next `PC` |
| `Branch` | 1-bit | Combined with ALU `Zero` flag (`Branch & Zero`) to select `PC + SignExt(imm6)` |
| `MemtoReg` | 1-bit | Selects Data Memory read output (`1`) vs. ALU result (`0`) for register write-back |
| `MemRead` | 1-bit | Enables combinational read from Data Memory |
| `MemWrite` | 1-bit | Enables synchronous write to Data Memory on rising clock edge |
| `ALUOp` | 3-bit | Selects the arithmetic or logic operation performed by the ALU |
| `ALUSrc` | 1-bit | Selects sign-extended immediate (`1`) vs. `Read Data 2` (`0`) for ALU input B |
| `RegWrite` | 1-bit | Enables synchronous write to `Write Register 3` on rising clock edge |

---

## Repository Structure

```text
.
├── architecture.png   # Full datapath & control block diagram
├── main.v             # Top-level CPU module interconnecting all datapath & control blocks
├── pc.v               # 16-bit Program Counter register
├── imem.v             # 64×16 Instruction Memory (loaded via $readmemb)
├── reg_file.v         # 8×16 Register File (2 combinational reads, 1 clocked write)
├── imm_gen.v          # Immediate generator (extracts and sign-extends Instruction[5:0])
├── control.v          # Main Control Unit decoding 4-bit opcodes
├── alu.v              # 16-bit Arithmetic Logic Unit with Zero flag output
├── dmem.v             # 64×16 Data Memory
├── tb_top.v           # Self-terminating testbench with watchdog timeout & VCD register dump
├── program1.mem       # Test Program 1: Basic arithmetic (ADDI, ADD, HLT)
└── program2.mem       # Test Program 2: Countdown loop from 10 to 0 (ADDI, SUB, BEQ, JMP, HLT)
```

---

## Verification & Example Programs

The testbench (`tb_top.v`) drives a 100 MHz simulated clock (`10 ns` period), applies an initial reset pulse, dumps all internal signals plus the 2D register file array (`uut.RF.registers[0:7]`) to `cpu_wave.vcd`, and automatically finishes once `halted` goes high (with a `1000 ns` failsafe watchdog timeout).

### `program1.mem` — Basic Arithmetic
Loads immediate constants into `R1` and `R2`, computes their sum into `R3`, and halts:
* `ADDI R1, R0, 5` → `R1 = 5`
* `ADDI R2, R0, 3` → `R2 = 3`
* `ADD  R3, R1, R2` → `R3 = 8`
* `HLT`

### `program2.mem` — Countdown Loop (10 → 0)
Verifies conditional branching (`BEQ`), subtraction (`SUB`), and unconditional looping (`JMP`):
* Initializes `R1 = 10` and `R2 = 1`
* Loops via `BEQ R1, R0, +3`, `SUB R1, R1, R2`, and `JMP 2`
* Branches directly to `HLT` when `R1` reaches `0` (verified via two's-complement ALU subtraction results stepping from `0xFFF6` (`-10`) up to `0x0000`)

---

## How to Simulate

### Prerequisites
* [Icarus Verilog (`iverilog` / `vvp`)](https://steveicarus.github.io/iverilog/)
* [GTKWave](https://gtkwave.sourceforge.net/)

### Steps
1. Open `imem.v` and select the desired program file in the `$readmemb` call (e.g., `program1.mem` or `program2.mem`).
2. Compile all Verilog modules:
   ```bash
   iverilog -o cpu_sim pc.v imem.v reg_file.v imm_gen.v control.v alu.v dmem.v main.v tb_top.v
   ```
3. Run the simulation:
   ```bash
   vvp cpu_sim
   ```
4. Open the generated waveform in GTKWave:
   ```bash
   gtkwave cpu_wave.vcd
   ```

---

## References
* David A. Patterson & John L. Hennessy, *Computer Organization and Design: The Hardware/Software Interface (RISC-V Edition)*, Morgan Kaufmann.
* Inspired by [RISC-V Single-Cycle Processor in Verilog | Full Design from Scratch](https://youtu.be/dh88oe6O0QU?si=v0gIi8zCIrU2RmII).