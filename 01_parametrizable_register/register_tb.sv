/*

    Testbench: Parametrizable N-bit Register with Enable and Asynchronous Reset

    This testbench verifies the DUT (Device Under Test) by simulating the 
    generation of a clock signal, applying the asynchronous reset, and 
    testing the capture/retention of a parameterized data bus through the enable signal.

    Author: André Solano F. R. Maiolini
    Date: 2026-04-27

*/

// Testbenches do not have inputs or outputs. It is a closed system.

module register_tb;

    // 'localparam' is the SystemVerilog equivalent of a constant.
    // We use it here to define the specific width we want to test, overriding the default.

    localparam int TEST_WIDTH = 16;

    // 1. Signal Declarations
    // Using 'logic' for all signals. Notice how the vectors are sized using TEST_WIDTH.

    logic                  clk;
    logic                  rst_n;
    logic                  en;
    logic [TEST_WIDTH-1:0] d;
    logic [TEST_WIDTH-1:0] q;

    // 2. DUT Instantiation
    // In VHDL, you would use "generic map (WIDTH => 16)". 
    // In SV, parameter overrides are passed using "#(.PARAM(value))" before the ports.

    register #(
        .WIDTH(TEST_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .d(d),
        .q(q)
    );

    // 3. Clock Generation
    // An 'always' block without a sensitivity list loops infinitely from time zero.

    always #5 clk = ~clk;

    // 4. Test Sequence (The 'initial' block)
    // The 'initial' block executes EXACTLY ONCE at the start of the simulation.

    initial begin
        
        // System Tasks for Waveform Generation (Essential for GTKWave)

        $dumpfile("dump.vcd");         // Creates the file expected by our Makefile
        $dumpvars(0, register_tb);     // '0' means "dump all signals in this module and below"

        // --- PHASE 1: Initialization and Reset ---

        clk = 0;
        en = 0;
        // In SV, the literal '0 automatically fills vectors of any size with zeros.
        d = '0; 
        rst_n = 0; // Assert reset (active-low)

        // Wait 15 time units (1.5 clock cycles) then release reset.

        #15 rst_n = 1; 

        // --- PHASE 2: Stimulus Injection ---

        // Test A: Write a hexadecimal value into the register

        @(negedge clk);
        // 16'hDEAD means: 16 bits wide, Hexadecimal format, value DEAD
        d = 16'hDEAD; 
        en = 1;

        // Wait for the next falling edge to assert the output.

        @(negedge clk);

        // '===' is a 4-state comparison operator that checks for both value and X/Z states.

        assert (q === 16'hDEAD) $display("✅ Test A passed: q captured 16'hDEAD when enable is 1"); 
        else $error("❌ Test A failed: q should be 16'hDEAD when enable is 1");

        // Test B: Disable enable and attempt to overwrite

        @(negedge clk);
        d = 16'hBEEF; // Change the input
        en = 0;       // Disable captures

        @(negedge clk);
        assert (q === 16'hDEAD) $display("✅ Test B passed: q retains 16'hDEAD when enable is 0"); 
        else $error("❌ Test B failed: q should retain 16'hDEAD when enable is 0");

        // Test C: Asynchronous Reset with a full bus

        @(negedge clk);
        d = 16'hFFFF; // Fill the bus with 1s
        en = 1;
        
        // Wait for the rising edge to capture FFFF, then simulate a small propagation delay
        
        @(posedge clk); 
        #1;             
        rst_n = 0; // Trigger reset asynchronously
        #1;

        // We use '0 in the assertion so the test automatically adapts if TEST_WIDTH changes.

        assert (q === '0) $display("✅ Test C passed: q resets to all zeros asynchronously"); 
        else $error("❌ Test C failed: q should reset to all zeros asynchronously");

        rst_n = 1; // Release reset

        // --- PHASE 3: Finish Simulation ---
        
        #20;
        $display("-------------------------------------------------------------------");
        $finish; // Instructs the simulator (Verilator) to terminate

    end

endmodule