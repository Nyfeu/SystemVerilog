/*
    RISC-V 32-bit Arithmetic Logic Unit (ALU)
    
    Features:
    - Implements all base integer (RV32I) ALU operations.
    - Utilizes SystemVerilog enumerated types for control signals.
    - Parameterized data width.

    Author: André Solano F. R. Maiolini
    Date: 2026-04-27

*/

// Include the package that contains the ALU operation codes (alu_op_e). The include guard in the package prevents multiple inclusions, so we can safely include it in both the ALU and the testbench without worrying about compilation errors.

`include "riscv_pkg.sv"

// Import the ALU operation codes from the package

import riscv_pkg::*;

module alu #(
    parameter int DATA_WIDTH = 32
)(
    input  logic [DATA_WIDTH-1:0] a,
    input  logic [DATA_WIDTH-1:0] b,
    input  alu_op_e  alu_op,  // New ENUM type for ALU_OP
    output logic [DATA_WIDTH-1:0] result,
    output logic                  zero
);

    // Pure combinational logic for the ALU operations

    always_comb begin
        
        // By default, we set the result to zero. This ensures that if an invalid ALU_OP is provided, the output will be zero instead of undefined (X).

        result = '0;
        
        // The case statement is a clean way to implement the ALU operations based on the control signal (alu_op). Each case corresponds to a specific ALU operation defined in the riscv_pkg.

        case (alu_op)
        
            ALU_ADD:  result = a + b;
            ALU_SUB:  result = a - b;
            ALU_SLL:  result = a << b[4:0]; // Shift left (only the lower 5 bits of b are used for shift amount)
            ALU_SRL:  result = a >> b[4:0]; // Logical shift right
            // Cast to signed ($signed) before shifting to ensure arithmetic shift right (SRA) behaves correctly for negative numbers.  
            ALU_SRA:  result = unsigned'($signed(a) >>> b[4:0]); 
            ALU_XOR:  result = a ^ b;
            ALU_OR:   result = a | b;
            ALU_AND:  result = a & b;
            ALU_SLT:  result = ($signed(a) < $signed(b)) ? (DATA_WIDTH)'(1) : '0; // Set less than signed
            ALU_SLTU: result = (a < b) ? (DATA_WIDTH)'(1) : '0;                   // Set less than unsigned
            default:  result = '0; 
        endcase
    end

    // The zero flag is set if the result of the ALU operation is zero. This is a common flag used in conditional branch instructions in RISC-V.

    // In SV, we can simply verify if the result is zero by comparing it to '0. The zero flag will be high (1) if the result is zero, and low (0) otherwise.

    assign zero = (result == '0);

endmodule