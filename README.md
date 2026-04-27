# 🚀 SystemVerilog Studies

Este repositório documenta minha transição e jornada de aprendizado em SystemVerilog, focando na modelagem de hardware para arquiteturas de processadores. 

## 🛠️ Setup e Execução

O repositório utiliza **Verilator** para simulação rápida e **GTKWave** para visualização de ondas. Existe um `Makefile` universal na raiz.

Para simular qualquer módulo, execute:
```bash
make sim DIR=<nome_da_pasta> MOD=<nome_do_modulo_base>
```

## 📚 Diário de Projetos e Conceitos Aprendidos

### - `00_d_flip_flop`

- **Conceito**: O bloco fundamental de memória.

- **Aprendizado**:
	- Uso do `module` para unificar a interface e implementação.
	- O tipo `logic` substitui as dores de cabeça do `wire`/`reg`.
	- Blocos sequenciais usam `always_ff @(posedge clk or negedge rst_n)`.
	- Importância da atribuição não-bloqueante (`<=`) para simular o paralelismo de registradores de hardware.

### - `01_parametrizable_register`

- **Conceito**: Registrador genérico de N-bits, a estrutura base para construir caminhos de dados (datapaths) flexíveis e redimensionáveis.

- **Aprendizado**:

	- Substituição do `generic` do VHDL pela declaração `parameter` (ex: `#(parameter int WIDTH = 32)`).

	- Sobrescrita de parâmetros durante a instanciação de módulos utilizando a sintaxe `#(.PARAM(valor))`.

	- O poder do literal `'0` (All Zeros) do SystemVerilog para preencher vetores de qualquer largura automaticamente no reset, eliminando o verboso `(others => '0')`.

	- Declaração de constantes locais de tempo de compilação usando `localparam` (ideal para testbenches).

	- Notação explícita de tamanho, base e valor para injeção de estímulos em barramentos de dados (ex: `16'hDEAD` para 16 bits em hexadecimal).

### - `02_riscv_base_blocks`

- **Conceito**: Blocos de hardware fundamentais da arquitetura RISC-V. 

- **Aprendizado**:
	- Declaração de memórias nativas usando Arrays Multidimensionais (*Unpacked Arrays*, ex: `logic [31:0] mem [0:31]`), substituindo a necessidade de criar `types` customizados como no VHDL.
	- Introdução ao bloco `always_comb` para modelar lógica combinacional pura com segurança e intenção clara.
	- Utilização do Operador Ternário (`condicao ? verdadeiro : falso`) para criar multiplexadores em uma única linha (essencial para a proteção do `x0`).
	- Uso do operador de deslocamento lógico (`<<`) para calcular dinamicamente a profundidade da memória baseada no parâmetro de endereços (`1 << ADDR_WIDTH`).
	- Prática de "Hexspeak" nos *testbenches* (ex: `32'hCAFE_BABE`, `32'hDEAD_BEEF`) para criar assinaturas visuais e facilitar o rastreamento de dados nas formas de onda geradas no GTKWave.

