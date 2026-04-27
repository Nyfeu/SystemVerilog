/*

    RISC-V Architecture Package
    Contains global types, enumerations, and constants for the core.

    Author: André Solano F. R. Maiolini
    Date: 2026-04-27

*/

// --- INCLUDE GUARD ---

// This prevents multiple inclusions of the same package, which can cause compilation errors. It's a common practice in both C/C++ and SystemVerilog.

`ifndef RISCV_PKG_SV
`define RISCV_PKG_SV

package riscv_pkg;

    // The convention in the industry is to add the suffix '_e' for Enums and '_t' for Structs/Custom Types. We follow this convention for clarity and maintainability.
    
    // ALU Operation Codes (ALU_OP)

    // These codes will be used to control the ALU's behavior in the execute stage.    

    typedef enum logic [3:0] {

        ALU_ADD  = 4'b0000,
        ALU_SLL  = 4'b0001,
        ALU_SLT  = 4'b0010,
        ALU_SLTU = 4'b0011,
        ALU_XOR  = 4'b0100,
        ALU_SRL  = 4'b0101,
        ALU_OR   = 4'b0110,
        ALU_AND  = 4'b0111,
        ALU_SUB  = 4'b1000,
        ALU_SRA  = 4'b1101

    } alu_op_e;

endpackage

`endif // RISCV_PKG_SV