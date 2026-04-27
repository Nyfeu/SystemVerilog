/*

    RISC-V 32-bit Register File
    
    Features:
    - 32 registers of 32 bits (parameterizable)
    - 2 asynchronous read ports
    - 1 synchronous write port
    - Register x0 is hardwired to zero (RISC-V standard)

    Author: André Solano F. R. Maiolini
    Date: 2026-04-27

*/

module reg_file #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 5   // 2^5 = 32 registers
)(
    input  logic                  clk,
    input  logic                  we,       // Write Enable
    input  logic [ADDR_WIDTH-1:0] rs1_addr, // Source Register 1 Address
    input  logic [ADDR_WIDTH-1:0] rs2_addr, // Source Register 2 Address
    input  logic [ADDR_WIDTH-1:0] rd_addr,  // Destination Register Address
    input  logic [DATA_WIDTH-1:0] rd_data,  // Data to write
    
    output logic [DATA_WIDTH-1:0] rs1_data, // Source Register 1 Data
    output logic [DATA_WIDTH-1:0] rs2_data  // Source Register 2 Data
);

    // SystemVerilog Array Declaration (Unpacked Array)
    // Read as: An array of (1<<ADDR_WIDTH) elements, where each element is DATA_WIDTH bits wide.
    logic [DATA_WIDTH-1:0] registers [0:(1<<ADDR_WIDTH)-1];

    // --- ASYNCHRONOUS READ ---

    // RISC-V explicitly requires register 0 (x0) to be hardwired to 0.
    
    // We use the ternary operator (condition ? true_val : false_val) for clean combinational logic.
    
    always_comb begin
        rs1_data = (rs1_addr == '0) ? '0 : registers[rs1_addr];
        rs2_data = (rs2_addr == '0) ? '0 : registers[rs2_addr];
    end

    // --- SYNCHRONOUS WRITE ---
    
    // Writes happen on the rising edge of the clock.
    // We explicitly prevent writing to x0, even if 'we' is high.

    always_ff @(posedge clk) begin
        if (we && (rd_addr != '0)) begin
            registers[rd_addr] <= rd_data;
        end
    end

endmodule