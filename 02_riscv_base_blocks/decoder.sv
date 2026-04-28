/*
    RISC-V Main Decoder
    
    Features:
    - Purely combinational logic.
    - Decodes standard RV32I opcodes into control signals.
    - Includes U-Type (LUI, AUIPC) and JALR support.
    - Generates alu_op_e directly, saving an ALU Decoder stage.

    Author: André Solano F. R. Maiolini
    Date: 2026-04-27
*/

`include "riscv_pkg.sv"
import riscv_pkg::*;

module decoder (
    input  logic [31:0] instr,
    
    // Control Signals Out
    output logic        reg_write,
    output logic        mem_read,
    output logic        mem_write,
    output logic        branch,
    output logic        jump,
    output logic [1:0]  alu_src_a,  // 00: rs1, 01: PC, 10: Zero
    output logic        alu_src_b,  // 0: rs2, 1: Imm
    output logic [1:0]  wb_src,     // 00: ALU, 01: Mem, 10: PC+4
    output alu_op_e     alu_op      // Direct ALU operation
);

    // --- SLICING (Aliasing) ---
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    
    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];

    // --- MAIN DECODE LOGIC ---
    always_comb begin
        // 1. DEFAULT VALUES (Prevents Latches and sets up NOP)
        reg_write  = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        branch     = 1'b0;
        jump       = 1'b0;
        alu_src_a  = 2'b00; // Default rs1
        alu_src_b  = 1'b0;  // Default rs2
        wb_src     = 2'b00; // Default ALU
        alu_op     = ALU_ADD; 

        // 2. OPCODE DECODING
        case (opcode)
            
            OP_R_TYPE: begin
                reg_write = 1'b1;
                // ALU Control Decode integrated
                if (funct3 == 3'b000 && funct7 == 7'b0100000) 
                    alu_op = ALU_SUB;
                else 
                    alu_op = ALU_ADD; // Simplified for ADD/SUB, you can expand later
            end

            OP_I_TYPE: begin
                reg_write = 1'b1;
                alu_src_b = 1'b1; // Imm
                alu_op    = ALU_ADD; 
            end

            OP_LOAD: begin
                reg_write = 1'b1;
                mem_read  = 1'b1;
                alu_src_b = 1'b1; // rs1 + Imm
                wb_src    = 2'b01; // Data from Memory
                alu_op    = ALU_ADD;
            end

            OP_STORE: begin
                mem_write = 1'b1;
                alu_src_b = 1'b1; // rs1 + Imm
                alu_op    = ALU_ADD;
            end

            OP_BRANCH: begin
                branch    = 1'b1;
                alu_op    = ALU_SUB; // rs1 - rs2 (sets Zero flag if equal)
            end
            
            OP_JAL: begin
                reg_write = 1'b1;
                jump      = 1'b1;
                wb_src    = 2'b10; // Save PC+4 to rd
            end

            OP_JALR: begin
                reg_write = 1'b1;
                jump      = 1'b1;
                alu_src_b = 1'b1;  // Calculate Target = rs1 + Imm
                wb_src    = 2'b10; // Save PC+4 to rd
                alu_op    = ALU_ADD;
            end

            OP_LUI: begin
                reg_write = 1'b1;
                alu_src_a = 2'b10; // Zero
                alu_src_b = 1'b1;  // Imm
                wb_src    = 2'b00; // ALU Output (0 + Imm)
                alu_op    = ALU_ADD;
            end

            OP_AUIPC: begin
                reg_write = 1'b1;
                alu_src_a = 2'b01; // PC
                alu_src_b = 1'b1;  // Imm
                wb_src    = 2'b00; // ALU Output (PC + Imm)
                alu_op    = ALU_ADD;
            end

            default: begin
                // All signals remain at default (NOP)
            end
        endcase
    end

endmodule