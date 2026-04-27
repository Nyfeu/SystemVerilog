/*
    Parametrizable N-bit Register with Enable and Asynchronous Reset

    In VHDL, you would use 'generic (WIDTH : integer := 32)'. 
    In SystemVerilog, we use '#(parameter int WIDTH = 32)'.
*/
module register #(
    parameter int WIDTH = 32 // O valor padrão é 32 bits se não for sobrescrito
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    input  logic [WIDTH-1:0] d, // O vetor tem tamanho WIDTH
    output logic [WIDTH-1:0] q
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // MÁGICA DO SV AQUI: Em VHDL seria "q <= (others => '0')"
            // Em SV, "'0" preenche automaticamente todos os bits do vetor com 0,
            // não importa o tamanho do WIDTH. E "'1" preenche tudo com 1.
            q <= '0; 
        end
        else if (en) begin
            q <= d;
        end
    end

endmodule