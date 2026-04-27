/*

    True Dual-Port RAM with Byte-Write Enable
    
    Features:
    - Inferred Block RAM (BRAM) for Xilinx Vivado.
    - Two independent ports (A and B) for simultaneous read/write.
    - Byte-level write mask (essential for RISC-V LSU).

    Author: André Solano F. R. Maiolini
    Date: 2026-04-27

*/

module dual_port_ram #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 10,
    localparam int BYTES = DATA_WIDTH / 8
)(
    input  logic clk,
    
    // Port A
    input  logic [BYTES-1:0] we_a, // Byte-write enable mask
    input  logic [ADDR_WIDTH-1:0] addr_a,
    input  logic [DATA_WIDTH-1:0] din_a,
    output logic [DATA_WIDTH-1:0] dout_a,
    
    // Port B
    input  logic [BYTES-1:0]      we_b,
    input  logic [ADDR_WIDTH-1:0] addr_b,
    input  logic [DATA_WIDTH-1:0] din_b,
    output logic [DATA_WIDTH-1:0] dout_b
);

    // Explicit BRAM inference attribute

    // It is crucial to use the correct attribute for BRAM inference. In Xilinx Vivado, the attribute (* ram_style = "block" *) tells the synthesis tool to implement this memory as a block RAM, which is optimized for FPGA architectures. This ensures that we get the performance and resource benefits of using BRAM instead of distributed logic.

    // If the ram_style attribute is not used, the synthesis tool might infer this as a large array of flip-flops (LUTRAM or distributed RAM), which is not efficient for larger memories. It can lead to a inneficient usage of FPGA resources.

    (* ram_style = "block" *) 
    logic [DATA_WIDTH-1:0] ram [0:(1<<ADDR_WIDTH)-1];

    // --- Port A Logic ---

    always_ff @(posedge clk) begin

        // Byte-write enable loop

        for (int i = 0; i < BYTES; i++) begin
            if (we_a[i]) begin
                ram[addr_a][(i*8) +: 8] <= din_a[(i*8) +: 8];
            end
        end

        // Synchronous read for BRAM inference

        dout_a <= ram[addr_a];

    end

    // --- Port B Logic ---
    
    always_ff @(posedge clk) begin
        for (int i = 0; i < BYTES; i++) begin
            if (we_b[i]) begin
                ram[addr_b][(i*8) +: 8] <= din_b[(i*8) +: 8];
            end
        end
        dout_b <= ram[addr_b];
    end

endmodule