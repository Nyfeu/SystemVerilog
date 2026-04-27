/*

    D Flip-Flop with Enable and Asynchronous Reset

    This module implements a D flip-flop that captures the value of the input 'd' on the rising edge of the clock 'clk' when the enable signal 'en' is high. The output 'q' is reset to 0 asynchronously when the reset signal 'rst_n' is low.

    Inputs:
    - clk: Clock signal (positive edge triggered)
    - rst_n: Active-low asynchronous reset signal
    - en: Enable signal for capturing the input
    - d: Data input to be captured

    Output:
    - q: Output that holds the captured value of 'd' or resets to 0 when 'rst_n' is low

    Author: André Solano F. R. Maiolini
    Date: 2026-04-27

*/ 

// In VHDL we need to define a entity (component interface) and architecture (component behavior), but in SystemVerilog (SV) we can directly define a module.

module d_flip_flop (

    input  logic clk,     // Clock signal
    input  logic rst_n,   // Active-low asynchronous reset signal
    input  logic en,      // Enable signal
    input  logic d,       // Data input 
    output logic q        // Output data

);

    /*
        Hardware Intent & Sensitivity List: 

        1. `always_ff`: Unlike the generic 'process' in VHDL or the legacy 'always' in Verilog, `always_ff` is a SystemVerilog directive that explicitly declares the designer's intent to model sequential logic (Flip-Flops). It acts as a strict Design Rule Check (DRC) during synthesis, throwing an error if the enclosed logic cannot be mapped to a physical flip-flop.
           
        2. `@(...)`: This is the sensitivity list. It dictates the exact physical events that "wake up" the block:
           
           - `posedge clk`: Triggers on the rising edge (0 to 1 transition) of the clock signal (Synchronous operation).
           
           - `negedge rst_n`: Triggers on the falling edge (1 to 0 transition) of the reset signal. Because this event is in the sensitivity list alongside the clock, the reset is evaluated immediately when it drops, making it an ASYNCHRONOUS reset.
    
    */

    always_ff @(posedge clk or negedge rst_n) begin

    // On the rising edge of the clock or when the reset signal goes low, we check the state of the reset and enable signals. If the reset signal is active (low), we set the output 'q' to 0. If the enable siignal is high, we capture the value of 'd' into 'q'. If neither condition is met, 'q' retains its previous value.

        if (!rst_n) begin
        
            // When the reset signal is active (low), we set the output 'q' to 0. 
        
            q <= 1'b0;

        end

        else if (en) begin

            // If the enable signal is high, we capture the value of 'd' into 'q'.
            
            q <= d;

        end

    end

endmodule