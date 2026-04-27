/*

    Testbench: D Flip-Flop with Enable and Asynchronous Reset

    This testbench verifies the DUT (Device Under Test) by simulating the 
    generation of a clock signal, applying the asynchronous reset, and 
    testing the capture/retention of data through the enable signal.

    Author: André Solano F. R. Maiolini
    Date: 2026-04-27

*/

// Testbenches do not have inputs or outputs. It is a closed system.

module d_flip_flop_tb;

    // 1. Signal Declarations
    // In VHDL, you would use 'signal' within the architecture. 
    // In SV, we use 'logic' to drive inputs into the DUT and monitor its outputs.

    logic clk;
    logic rst_n;
    logic en;
    logic d;
    logic q;

    // 2. DUT Instantiation
    // Instantiation by name. In VHDL: "port map (clk => clk)". In SV: ".port(signal)".

    d_flip_flop dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .d(d),
        .q(q)
    );

    // 3. Clock Generation
    // An 'always' block without a sensitivity list loops infinitely from time zero.
    // The '#5' means "delay for 5 time units". This inverts the clock every 5 units,
    // yielding a period of 10 time units.

    always #5 clk = ~clk;

    // 4. Test Sequence (The 'initial' block)
    // The 'initial' block executes EXACTLY ONCE at the start of the simulation.
    // It executes sequentially (top to bottom), making it perfect for writing step-by-step test vectors.

    initial begin
        
        // System Tasks for Waveform Generation (Essential for GTKWave)

        $dumpfile("dump.vcd");         // Creates the file expected by our Makefile
        $dumpvars(0, d_flip_flop_tb);  // '0' means "dump all signals in this module and below"

        // --- PHASE 1: Initialization and Reset ---

        clk = 0;
        en = 0;
        d = 0;
        rst_n = 0; // Assert reset (active-low)

        // Wait 15 time units (1.5 clock cycles) then release reset.
        // Releasing reset off the clock edge is a good practice to visualize asynchronous behavior.

        #15 rst_n = 1; 

        // --- PHASE 2: Stimulus Injection ---

        // Using '@(negedge clk)' pauses the execution until the clock falls.
        // We change inputs on the falling edge so they are perfectly stable 
        // when the rising edge arrives (simulating setup time margins).

        // Test A: Try to write data without Enable

        @(negedge clk);
        d = 1;
        en = 0; // 'q' should remain 0

        // Wait for the next falling edge to assert the output.

        @(negedge clk);

        // '===' is a 4-state comparison operator that checks for both value and X/Z states.
        // If 'q' is 0, the test passes. If 'q' is 1 or X/Z, the test fails.

        assert (q === 1'b0) $display("✅ Test A passed: q is 0 when enable is 0"); 
        else $error("❌ Test A failed: q should be 0 when enable is 0");

        // Test B: Write data WITH Enable

        @(negedge clk);
        d = 1;
        en = 1; // 'q' should become 1 on the next rising edge

        @(negedge clk);
        assert (q === 1'b1) $display("✅ Test B passed: q is 1 when enable is 1"); 
        else $error("❌ Test B failed: q should be 1 when enable is 1");

        // Test C: Change data input

        @(negedge clk);
        d = 0; // 'q' should become 0

        @(negedge clk);
        assert (q === 1'b0) $display("✅ Test C passed: q is 0 after changing d to 0"); 
        else $error("❌ Test C failed: q should be 0 after changing d to 0");

        // Test D: Disable and hold value

        @(negedge clk);
        en = 0;
        d = 1; // 'd' changed to 1, but 'en' is 0, so 'q' MUST retain 0

        @(negedge clk);
        assert (q === 1'b0) $display("✅ Test D passed: q retains 0 when enable is 0"); 
        else $error("❌ Test D failed: q should retain 0 when enable is 0");

        // Test E: Asynchronous Reset during operation

        @(negedge clk);
        en = 1;
        d = 1;
        // Wait just 3 time units (before the next rising edge) and trigger reset
        #3 rst_n = 0; // 'q' MUST drop to 0 instantly, ignoring the clock

        @(negedge clk);
        assert (q === 1'b0) $display("✅ Test E passed: q resets to 0 asynchronously"); 
        else $error("❌ Test E failed: q should reset to 0 asynchronously");

        // --- PHASE 3: Finish Simulation ---
        
        #20;
        $display("-------------------------------------------------------------------");
        $finish; // Instructs the simulator (Verilator) to terminate


    end

endmodule