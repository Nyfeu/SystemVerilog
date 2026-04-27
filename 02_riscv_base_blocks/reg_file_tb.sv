/*

    Testbench: RISC-V 32-bit Register File

    This testbench verifies the DUT (Device Under Test) by simulating:
    1. The hardwired zero behavior of register x0.
    2. Synchronous writes to general purpose registers.
    3. Asynchronous reads from both rs1 and rs2 ports.
    4. The Write Enable (we) control signal.

    Author: André Solano F. R. Maiolini
    Date: 2026-04-27

*/

module reg_file_tb;

    // Parameters for the testbench
    localparam int DATA_WIDTH = 32;
    localparam int ADDR_WIDTH = 5;

    // 1. Signal Declarations

    logic clk;
    logic we;
    
    logic [ADDR_WIDTH-1:0] rs1_addr;
    logic [ADDR_WIDTH-1:0] rs2_addr;
    logic [ADDR_WIDTH-1:0] rd_addr;
    logic [DATA_WIDTH-1:0] rd_data;
    
    logic [DATA_WIDTH-1:0] rs1_data;
    logic [DATA_WIDTH-1:0] rs2_data;

    // 2. DUT Instantiation

    reg_file #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .we(we),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // 3. Clock Generation

    always #5 clk = ~clk;

    // 4. Test Sequence
    
    initial begin
        
        // System Tasks for Waveform Generation
        
        $dumpfile("dump.vcd");         
        $dumpvars(0, reg_file_tb);     

        // --- PHASE 1: Initialization ---
        
        clk = 0;
        we = 0;
        rs1_addr = '0;
        rs2_addr = '0;
        rd_addr = '0;
        rd_data = '0;

        // Wait a few cycles before starting
        
        #15;

        // --- PHASE 2: Stimulus Injection & Assertions ---

        // Test A: Check hardwired zero (x0) behavior
        
        @(negedge clk);
        rd_addr = 5'd0;           // Address 0
        rd_data = 32'hFFFF_FFFF;  // Try to write all 1s
        we = 1;
        
        @(negedge clk);
        we = 0;
        rs1_addr = 5'd0;          // Read from x0

        // Note: we use n' to indicate the width of the literal. It's important to match the width of the literal with the signal width to avoid unintended truncation or extension. If the WIDTH params are changed, the literals will raise a warning if they don't match the expected width.

        // In SV, #1 acts as a tiny propagation delay to let combinational logic settle

        #1;

        // Assert that x0 is still zero, regardless of the write attempt

        assert (rs1_data === 32'd0) $display("✅ Test A passed: Register x0 is hardwired to 0 and cannot be overwritten"); 
        else $error("❌ Test A failed: Register x0 was overwritten!");

        // Test B: Normal Synchronous Write and Asynchronous Read
        
        @(negedge clk);
        rd_addr = 5'd10;      // Target register x10 (a0 in RISC-V)
        rd_data = 32'hCAFE_BABE; 
        we = 1;

        @(negedge clk);
        we = 0;

        // Asynchronous read: as soon as we change the address, data should appear immediately
        
        rs1_addr = 5'd10;
        rs2_addr = 5'd10;
        
        #1; // Combinational settling time
        
        assert (rs1_data === 32'hCAFE_BABE && rs2_data === 32'hCAFE_BABE) $display("✅ Test B passed: Data correctly written to and read from x10"); 
        else $error("❌ Test B failed: Incorrect data read from x10");

        // Test C: Write Enable disabled

        @(negedge clk);
        rd_addr = 5'd15;      // Target register x15 (a5)
        rd_data = 32'hDEAD_BEEF; 
        we = 0;               // WRITE ENABLE IS 0

        @(negedge clk);
        rs1_addr = 5'd15;
        
        #1;
        assert (rs1_data === 32'd0) $display("✅ Test C passed: Write ignored when 'we' is 0"); 
        else $error("❌ Test C failed: Data written even though 'we' was 0");

        // Test D: Dual Port Read Verification

        @(negedge clk);
        
        // Write to x5
        
        rd_addr = 5'd5;
        rd_data = 32'h1111_1111;
        we = 1;
        
        @(negedge clk);
        
        // Write to x6
        
        rd_addr = 5'd6;
        rd_data = 32'h2222_2222;
        we = 1;

        @(negedge clk);
        we = 0;
        
        // Read x5 from port 1 and x6 from port 2 simultaneously
        
        rs1_addr = 5'd5;
        rs2_addr = 5'd6;

        #1;

        assert (rs1_data === 32'h1111_1111 && rs2_data === 32'h2222_2222) $display("✅ Test D passed: Dual port asynchronous read successful"); 
        else $error("❌ Test D failed: Dual port read conflict");

        // --- PHASE 3: Finish Simulation ---

        #20;
        $display("-------------------------------------------------------------------");
        $finish; 

    end

endmodule