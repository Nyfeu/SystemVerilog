/*

    Dual-Port Synchronous Boot ROM
    
    Features:
    - Inferred Block RAM (BRAM) initialization.
    - Native hex file loading via $readmemh.
    - Two synchronous read ports (Instruction Fetch & Data Read).
    - Parameterizable depth and initialization file.

    Author: André Solano F. R. Maiolini
    Date: 2026-04-27

*/

module boot_rom #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 10,
    parameter string INIT_FILE = "03_memories/program.hex" // The jump of the cat!
)(

    input  logic                  clk,
    
    // Port A: Instruction Fetch

    input  logic [ADDR_WIDTH-1:0] addr_a,
    output logic [DATA_WIDTH-1:0] dout_a,
    
    // Port B: Data / Constants Read

    input  logic [ADDR_WIDTH-1:0] addr_b,
    output logic [DATA_WIDTH-1:0] dout_b

);

    // BRAM inference attribute

    (* ram_style = "block" *) 
    logic [DATA_WIDTH-1:0] rom [0:(1<<ADDR_WIDTH)-1];

    // --- INITIALIZATION ---

    // This initial block runs at time 0 of the simulatioin and is recognized by VIVADO during synthesis to generate the .mif file for the BRAM.

    initial begin

        if (INIT_FILE != "") begin

            // If an initialization file is provided, load it into the ROM. The file should be in hex format, matching the DATA_WIDTH of the ROM. Each line corresponds to one address, starting from 0. If the file has fewer lines than the ROM depth, the remaining addresses will be initialized to zero.

            $readmemh(INIT_FILE, rom);
        
        end else begin
            
            // If no initialization file is provided, initialize the ROM to zero. This is important to avoid undefined behavior during simulation and to ensure a known state for the ROM.

            for (int i = 0; i < (1<<ADDR_WIDTH); i++) begin
                rom[i] = '0;
            end

        end

    end

    // --- SYNCHRONOUS READS ---

    // One clock cycle read latency is required for BRAM inference. Both ports read from the same ROM array, but they can be accessed independently.

    always_ff @(posedge clk) begin
        dout_a <= rom[addr_a];
        dout_b <= rom[addr_b];
    end

endmodule