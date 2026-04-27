/*

    Testbench: RISC-V 32-bit Arithmetic Logic Unit (ALU)

    This testbench verifies the DUT (Device Under Test) by simulating
    various arithmetic, logical, shift, and comparison operations.
    It specifically tests signed vs unsigned behaviors (SRA, SLT, SLTU)
    and the zero flag.

    Author: André Solano F. R. Maiolini
    Date: 2026-04-27

*/

// Include the package that contains the ALU operation codes (alu_op_e). The include guard in the package prevents multiple inclusions, so we can safely include it in both the ALU and the testbench without worrying about compilation errors.

`include "riscv_pkg.sv" 

// Import the package containing alu_op_e

import riscv_pkg::*;    

// Testbenches do not have inputs or outputs. It is a closed system.

module alu_tb;

    localparam int DATA_WIDTH = 32;

    // 1. Signal Declarations
    
    logic                  clk; // Used purely for synchronizing test steps in the waveform
    logic [DATA_WIDTH-1:0] a;
    logic [DATA_WIDTH-1:0] b;
    alu_op_e               alu_op;
    
    logic [DATA_WIDTH-1:0] result;
    logic                  zero;

    // 2. DUT Instantiation
    
    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .result(result),
        .zero(zero)
    );

    // 3. Clock Generation
    
    always #5 clk = ~clk;

    // 4. Test Sequence (The 'initial' block)
    
    initial begin
        
        // System Tasks for Waveform Generation
        $dumpfile("dump.vcd");         
        $dumpvars(0, alu_tb);  

        // --- PHASE 1: Initialization ---

        clk = 0;
        a = '0;
        b = '0;
        alu_op = ALU_ADD;

        #15; // Wait a few cycles before starting

        // --- PHASE 2: Stimulus Injection ---

        // Test A: Addition and Zero Flag (False)

        @(negedge clk);
        a = 32'd15;
        b = 32'd10;
        alu_op = ALU_ADD;

        @(negedge clk);
        assert (result === 32'd25 && zero === 1'b0) $display("✅ Test A passed: Addition works"); 
        else $error("❌ Test A failed: Addition result incorrect");

        // Test B: Subtraction resulting in Zero

        @(negedge clk);
        a = 32'hCAFE_BABE;
        b = 32'hCAFE_BABE;
        alu_op = ALU_SUB;

        @(negedge clk);
        assert (result === 32'd0 && zero === 1'b1) $display("✅ Test B passed: Subtraction and Zero flag work"); 
        else $error("❌ Test B failed: Subtraction or Zero flag incorrect");

        // Test C: Logical Operations (XOR)

        @(negedge clk);
        a = 32'hFFFF_0000;
        b = 32'hF0F0_F0F0;
        alu_op = ALU_XOR;

        @(negedge clk);
        // XORing F with F gives 0. F with 0 gives F.
        assert (result === 32'h0F0F_F0F0) $display("✅ Test C passed: XOR operation works"); 
        else $error("❌ Test C failed: XOR result incorrect");

        // Test D: Shift Right Arithmetic (SRA) with a negative number
        
        @(negedge clk);
        a = 32'hF000_0000; // MSB is 1 (Negative in 2's complement)
        b = 32'd4;         // Shift right by 4 bits
        alu_op = ALU_SRA;

        @(negedge clk);
        // SRA should sign-extend, bringing in 1s from the left: F000_0000 -> FF00_0000
        assert (result === 32'hFF00_0000) $display("✅ Test D passed: SRA sign-extends correctly"); 
        else $error("❌ Test D failed: SRA did not sign-extend");

        // Test E: Shift Right Logical (SRL) with a negative number
        
        @(negedge clk);
        a = 32'hF000_0000;
        b = 32'd4;
        alu_op = ALU_SRL;

        @(negedge clk);
        // SRL should zero-fill, bringing in 0s from the left: F000_0000 -> 0F00_0000
        assert (result === 32'h0F00_0000) $display("✅ Test E passed: SRL zero-fills correctly"); 
        else $error("❌ Test E failed: SRL did not zero-fill");

        // Test F: Set Less Than (SLT) - Signed comparison
        
        @(negedge clk);
        a = 32'hFFFF_FFFF; // -1 in 2's complement
        b = 32'h0000_0001; //  1 in 2's complement
        alu_op = ALU_SLT;

        @(negedge clk);
        // Since -1 < 1, result should be 1
        assert (result === 32'd1) $display("✅ Test F passed: SLT signed comparison works (-1 < 1)"); 
        else $error("❌ Test F failed: SLT signed comparison incorrect");

        // Test G: Set Less Than Unsigned (SLTU) - Unsigned comparison
        
        @(negedge clk);
        a = 32'hFFFF_FFFF; // Maximum 32-bit unsigned integer (4,294,967,295)
        b = 32'h0000_0001; // 1
        alu_op = ALU_SLTU;

        @(negedge clk);
        // Since MaxInt is NOT less than 1, result should be 0
        assert (result === 32'd0) $display("✅ Test G passed: SLTU unsigned comparison works (MaxInt is not < 1)"); 
        else $error("❌ Test G failed: SLTU unsigned comparison incorrect");

        // --- PHASE 3: Finish Simulation ---
        
        #20;
        $display("-------------------------------------------------------------------");
        $finish; 

    end

endmodule