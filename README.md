# RISC_V_basic
Implementation of 32-bit RISC-V processor with basic instruction sets
# RISC-V Project (MIPS32)

## Overview

This repository documents the design and architectural details of a processor core inspired by the **RISC-V** and **MIPS32** instruction set architectures. The project emphasizes a minimal instruction set to enable efficient hardware and software design and provides a clear foundation for extensibility and experimentation.

---

## Key Features

- **Small core set of instructions** for streamlined design and software execution.
- **Optimal extensibility** and flexibility to select only required features.
- **Simple instruction sets** for various tasks.
- **Common ISA** usable from basic embedded systems to supercomputers.
- **RISC architecture:** Fewer instructions, more registers.

---

## MIPS32 Architecture Summary

- **32 general-purpose registers** (`32-bit` each; `R0` is always 0; used for temporary storage during computation)
- **32-bit Program Counter (PC):** Points to next instruction in memory.
- **No dedicated flag register.**
- **Few addressing modes.**
- **Memory access:** Only `load` and `store` instructions can access memory. All others operate exclusively on registers.
- **Word addressable memory** (32-bit word size).

---

## Subset Instruction Set

### Load & Store

- `LW R2, #124(R8)`  // R2 = Mem[R8+124]
- `SW R5, #10(R25)`  // Mem[R25+10] = R5

### Arithmetic & Logic (Register-to-Register)

- General Format: `Inst A, B, C` → `A = B op C`
- Supported instructions:
  - `ADD`
  - `SUB`
  - `AND`
  - `OR`
  - `MUL`
  - `Div`
  - `Eq`
  - `Jmp`
  - `SLT` (Set Less Than)

### Arithmetic & Logic (Immediate)

- General Format: `Inst A, B, X` → `A = B op X`
- Supported instructions:
  - `ADDI`
  - `SUBI`
  - `SLTI`

### Branch

- `BEZ R1, label` // If `R1 == 0`, PC moves to `label`
- `BNEZ R1, label` // If `R1 != 0`, PC moves to `label`

### Jump (Not implemented)

- `J label`

### Miscellaneous

- `HLT` // Halt instruction

---

## Instruction Encoding

### R-type (Register)

| 31-26  | 25-21 | 20-16 | 15-11 | 10-6 | 5-0  |
|--------|-------|-------|-------|------|------|
| opcode |  rs   |  rt   |  rd   |shamt |funct |

- Used for arithmetic and halt instructions.

### I-type (Immediate)

| 31-26  | 25-21 | 20-16 | 15-0 (imm) |
|--------|-------|-------|------------|
| opcode |  rs   |  rd   |  immediate |

- Used for load/store, branch, and immediate instructions.

### J-type (Jump, not implemented)

| 31-26  | 25-0    |
|--------|---------|
| opcode | immdata |

---

## Processor Operation Steps

1. **Instruction Fetch**
   - `IF: IR ← Mem[PC]`
   - `NPC ← PC + 1` (word addressable)
2. **Instruction Decode & Register Fetch**
   - Decode instruction; fetch `rs`, `rt` in parallel
   - Sign-extend 16-bit immediate if needed
3. **Execution / Effective Address Calculation**
   - Load/store: `ALUOut ← A + Imm`
   - Register ALU: `ALUOut ← A op B`
   - Branch: `ALUOut ← NPC + Imm`; condition evaluated
4. **Memory Access / Branch Completion**
   - `Load: LMD ← Mem[ALUOut]`
   - `Store: Mem[ALUOut] ← B`
   - For branch: `if (cond) PC ← ALUOut else PC ← NPC`
5. **Register Write Back**
   - R-type: `Reg[rd] ← ALUOut`
   - I-type: `Reg[rt] ← LMD`
   - No write-back for store and branch

---

## Pipelining

The processor uses a classic five-stage pipeline:

| Stage | Name                 | Pipeline Register |
|-------|----------------------|------------------|
|  1    | IF (Instr. Fetch)    | L1               |
|  2    | ID (Instr. Decode)   | L2               |
|  3    | EX (Execute)         | L3               |
|  4    | MEM (Memory Access)  | L4               |
|  5    | WB (Write Back)      |                  |

**Pipeline Registers Per Stage:**
- IF–ID: IR, NPC
- ID–EX: A, B, Imm
- EX–MEM: ALUOut, cond
- MEM–WB: ALUOut, LMD

---

## Additional Notes

- Register R0 is always 0 and cannot be overwritten.
- All immediate values are sign-extended to 32 bits.
- Only load/store instructions access memory; others operate on CPU registers.
- J-type (Jump) not implemented in this subset.

---
