/*
    Testbench: RISC-V Main Decoder

    Author: André Solano F. R. Maiolini
    Date: 2026-04-27
*/

`include "riscv_pkg.sv"
import riscv_pkg::*;

module decoder_tb;

    // 1. Signal Declarations
    logic [31:0] instr;
    
    logic        reg_write;
    logic        mem_read;
    logic        mem_write;
    logic        branch;
    logic        jump;
    logic [1:0]  alu_src_a;
    logic        alu_src_b;
    logic [1:0]  wb_src;
    alu_op_e     alu_op;

    // 2. DUT Instantiation
    decoder dut (
        .instr(instr),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .jump(jump),
        .alu_src_a(alu_src_a),
        .alu_src_b(alu_src_b),
        .wb_src(wb_src),
        .alu_op(alu_op)
    );

    // 3. Test Sequence
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, decoder_tb);

        #10;

        // Test A: ADD x5, x6, x7 (Opcode: 0110011)
        instr = 32'h0073_02B3;
        #5;
        assert (reg_write == 1 && alu_src_a == 2'b00 && alu_src_b == 0 && wb_src == 2'b00) 
            $display("✅ Test A passed: R-Type ADD correctly decoded.");
        else $error("❌ Test A failed: R-Type ADD incorrect.");

        // Test B: LW x10, 8(x11) (Opcode: 0000011)
        instr = 32'h0085_A503;
        #5;
        assert (reg_write == 1 && mem_read == 1 && alu_src_b == 1 && wb_src == 2'b01) 
            $display("✅ Test B passed: Load Word (LW) correctly decoded.");
        else $error("❌ Test B failed: Load Word incorrect.");

        // Test C: LUI x5, 0x12345 (Opcode: 0110111)
        // Expected: reg_write=1, alu_src_a=10 (Zero), alu_src_b=1 (Imm)
        instr = 32'h1234_52B7;
        #5;
        assert (reg_write == 1 && alu_src_a == 2'b10 && alu_src_b == 1 && wb_src == 2'b00) 
            $display("✅ Test C passed: LUI correctly routes Zero and Imm to ALU.");
        else $error("❌ Test C failed: LUI incorrect.");

        // Test D: AUIPC x6, 0x54321 (Opcode: 0010111)
        // Expected: reg_write=1, alu_src_a=01 (PC), alu_src_b=1 (Imm)
        instr = 32'h5432_1317;
        #5;
        assert (reg_write == 1 && alu_src_a == 2'b01 && alu_src_b == 1 && wb_src == 2'b00) 
            $display("✅ Test D passed: AUIPC correctly routes PC and Imm to ALU.");
        else $error("❌ Test D failed: AUIPC incorrect.");

        #10;
        $display("-------------------------------------------------------------------");
        $finish;
    end

endmodule