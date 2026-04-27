/*
    
    Parametrizable N-bit Register with Enable and Asynchronous Reset

    In VHDL, you would use 'generic (WIDTH : integer := 32)'. 
    In SystemVerilog, we use '#(parameter int WIDTH = 32)'.

    Author: André Solano F. R. Maiolini
    Date: 2026-04-27

*/

module register #(
    parameter int WIDTH = 32 // The default width is 32 bits if not overridden
)(
    input  logic clk,
    input  logic rst_n,
    input  logic en,
    input  logic [WIDTH-1:0] d, // The vector has size WIDTH
    output logic [WIDTH-1:0] q
);

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            // '0 is a SystemVerilog literal that fills the entire vector with zeros, regardless of WIDTH.
            
            // While '1 would fill the vector with ones. This is a convenient way to initialize vectors without worrying about their size.

            q <= '0;

        end

        else if (en) begin
        
            q <= d;
        
        end

    end

endmodule