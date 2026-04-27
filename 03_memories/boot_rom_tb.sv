/*

    Testbench: Dual-Port Synchronous Boot ROM

    This testbench verifies:
    1. The correct initialization of the ROM from a .hex file.
    2. Synchronous read latency (1 cycle).
    3. Independent dual-port simultaneous reads.

    Author: André Solano F. R. Maiolini
    Date: 2026-04-27

*/

module boot_rom_tb;

    localparam int DATA_WIDTH = 32;
    localparam int ADDR_WIDTH = 8; // 256 words
    
    // 1. Signal Declarations
    logic                  clk;
    
    logic [ADDR_WIDTH-1:0] addr_a;
    logic [DATA_WIDTH-1:0] dout_a;
    
    logic [ADDR_WIDTH-1:0] addr_b;
    logic [DATA_WIDTH-1:0] dout_b;

    // 2. DUT Instantiation
    boot_rom #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .INIT_FILE("03_memories/program.hex") // Indicate the initialization file for the ROM. This file should be in the same directory as the testbench and contain the hex values to initialize the ROM.
    ) dut (
        .clk(clk),
        .addr_a(addr_a),
        .dout_a(dout_a),
        .addr_b(addr_b),
        .dout_b(dout_b)
    );

    // 3. Clock Generation
    always #5 clk = ~clk;

    // 4. Test Sequence
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, boot_rom_tb);

        // --- PHASE 1: Initialization ---
        clk = 0;
        addr_a = '0;
        addr_b = '0;
        #15;

        // --- PHASE 2: Stimulus Injection ---

        // Test A: Read address 0 from Port A (Should be 00000013)
        @(negedge clk);
        addr_a = 8'd0;

        @(negedge clk); // Sync read wait
        assert (dout_a === 32'h0000_0013) 
            $display("✅ Test A passed: Successfully loaded and read address 0x0.");
        else $error("❌ Test A failed: Incorrect data at address 0x0.");

        // Test B: Read address 3 from Port B (Should be CAFEBABE)
        @(negedge clk);
        addr_b = 8'd3;

        @(negedge clk); // Sync read wait
        assert (dout_b === 32'hCAFE_BABE) 
            $display("✅ Test B passed: Successfully read hex constant at address 0x3.");
        else $error("❌ Test B failed: Incorrect data at address 0x3.");

        // Test C: Simultaneous Reads (Port A reads addr 4, Port B reads addr 1)
        @(negedge clk);
        addr_a = 8'd4; // Expected: DEADBEEF
        addr_b = 8'd1; // Expected: 00100093

        @(negedge clk); // Sync read wait
        assert (dout_a === 32'hDEAD_BEEF && dout_b === 32'h0010_0093) 
            $display("✅ Test C passed: Dual-port simultaneous read successful.");
        else $error("❌ Test C failed: Read collision or incorrect data.");

        // --- PHASE 3: Finish Simulation ---
        #20;
        $display("-------------------------------------------------------------------");
        $finish;
    end

endmodule