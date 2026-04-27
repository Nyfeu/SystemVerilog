/*

    Testbench: True Dual-Port RAM with Byte-Write Enable

    This testbench verifies:
    1. Synchronous read latency (BRAM inference requirement).
    2. Full word writing (4 bytes enabled).
    3. Partial word writing (Byte-Write Enable) to simulate RISC-V 'sb'/'sh'.
    4. Independent dual-port operation.

    Author: André Solano F. R. Maiolini
    Date: 2026-04-27

*/

module dual_port_ram_tb;

    localparam int DATA_WIDTH = 32;
    localparam int ADDR_WIDTH = 8; // 256 words for simulation
    localparam int BYTES = DATA_WIDTH / 8;

    // 1. Signal Declarations
    logic                  clk;
    
    // Port A
    logic [BYTES-1:0]      we_a;
    logic [ADDR_WIDTH-1:0] addr_a;
    logic [DATA_WIDTH-1:0] din_a;
    logic [DATA_WIDTH-1:0] dout_a;
    
    // Port B
    logic [BYTES-1:0]      we_b;
    logic [ADDR_WIDTH-1:0] addr_b;
    logic [DATA_WIDTH-1:0] din_b;
    logic [DATA_WIDTH-1:0] dout_b;

    // 2. DUT Instantiation
    dual_port_ram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .we_a(we_a),
        .addr_a(addr_a),
        .din_a(din_a),
        .dout_a(dout_a),
        .we_b(we_b),
        .addr_b(addr_b),
        .din_b(din_b),
        .dout_b(dout_b)
    );

    // 3. Clock Generation
    always #5 clk = ~clk;

    // 4. Test Sequence
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, dual_port_ram_tb);

        // --- PHASE 1: Initialization ---
        clk = 0;
        we_a = '0; addr_a = '0; din_a = '0;
        we_b = '0; addr_b = '0; din_b = '0;
        #15;

        // --- PHASE 2: Stimulus Injection ---

        // Test A: Write a FULL WORD via Port A
        // Simulates RISC-V 'sw' (Store Word)
        @(negedge clk);
        addr_a = 8'h10;
        din_a  = 32'hDEAD_BEEF;
        we_a   = 4'b1111; // Enable all 4 bytes

        @(negedge clk);
        we_a   = 4'b0000; // Stop writing
        
        // Let's read it back via Port B to prove Dual-Port works
        addr_b = 8'h10;
        
        // Wait for the synchronous read to complete (1 cycle latency)
        @(negedge clk); 
        
        assert (dout_b === 32'hDEAD_BEEF) 
            $display("✅ Test A passed: Full word successfully written (Port A) and read (Port B).");
        else $error("❌ Test A failed: Full word read/write mismatch.");


        // Test B: Partial Write (BYTE-WRITE) via Port B
        // Simulates RISC-V 'sb' (Store Byte). We want to overwrite ONLY the lowest byte ('EF' -> 'AA')
        // Expected result in memory: DEAD_BEAA
        @(negedge clk);
        addr_b = 8'h10;
        din_b  = 32'h0000_00AA; // The data we want to inject
        we_b   = 4'b0001;       // Enable ONLY the lowest byte (Byte 0)

        @(negedge clk);
        we_b   = 4'b0000; // Stop writing
        
        // Read it back via Port A
        addr_a = 8'h10;
        
        @(negedge clk); // Sync read wait
        
        assert (dout_a === 32'hDEAD_BEAA) 
            $display("✅ Test B passed: Byte-write successful! Only the lowest byte was modified.");
        else $error("❌ Test B failed: Byte-write corrupted other bytes or failed to write.");


        // Test C: Simultaneous independent operations
        // Port A writes to 0x20. Port B reads from 0x10.
        @(negedge clk);
        addr_a = 8'h20;
        din_a  = 32'hCAFE_BABE;
        we_a   = 4'b1111; // Write full word
        
        addr_b = 8'h10;   // Read previous byte-modified word
        we_b   = 4'b0000;

        @(negedge clk);
        we_a   = 4'b0000;
        
        assert (dout_b === 32'hDEAD_BEAA) 
            $display("✅ Test C passed: Port B read successfully while Port A was writing.");
        else $error("❌ Test C failed: Read collision.");


        // --- PHASE 3: Finish Simulation ---
        #20;
        $display("-------------------------------------------------------------------");
        $finish;
    end

endmodule