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

    // --- RISC-V RV32I Opcodes ---

    // OP_CODE constants for the RV32I base instruction set. These will be used in the instruction decode stage to identify the type of instruction and control the datapath accordingly.
    
    localparam logic [6:0] OP_LOAD   = 7'b0000011;
    localparam logic [6:0] OP_STORE  = 7'b0100011;
    localparam logic [6:0] OP_BRANCH = 7'b1100011;
    localparam logic [6:0] OP_JAL    = 7'b1101111;
    localparam logic [6:0] OP_JALR   = 7'b1100111;
    localparam logic [6:0] OP_LUI    = 7'b0110111;
    localparam logic [6:0] OP_AUIPC  = 7'b0010111;
    localparam logic [6:0] OP_I_TYPE = 7'b0010011;
    localparam logic [6:0] OP_R_TYPE = 7'b0110011;

endpackage

`endif // RISCV_PKG_SV