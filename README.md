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

- **Conceito**: Blocos de hardware fundamentais da arquitetura RISC-V. A implementação abrange o Banco de Registradores (*Register File*) — garantindo a regra de *hardwired zero* no registrador `x0` — e a Unidade Lógica Aritmética (ALU), acompanhada de um pacote global de definições da arquitetura.

- **Aprendizado**:
	- Declaração de memórias nativas usando Arrays Multidimensionais (*Unpacked Arrays*, ex: `logic [31:0] mem [0:31]`), substituindo a necessidade de criar `types` customizados como no VHDL.
	- Introdução ao bloco `always_comb` para modelar lógica combinacional pura com segurança e intenção clara.
	- Utilização do Operador Ternário (`condicao ? verdadeiro : falso`) para criar multiplexadores em uma única linha.
	- Criação de pacotes globais (`package` e `import`) para organizar definições, evitar a dispersão de constantes e manter o projeto portável.
	- Proteção de arquivos contra múltiplas inclusões utilizando **Include Guards** (`` `ifndef ``, `` `define ``, `` `endif ``), aplicando lógicas clássicas de pré-processamento do C/C++ ao design de hardware.
	- Uso de **Tipos Enumerados** (`typedef enum`) para garantir tipagem forte e legibilidade na roteirização de sinais de controle (ex: `ALU_ADD`, `ALU_SUB`).
	- Conversões seguras e limpas com a sintaxe `$signed()` para operações sensíveis a sinal, simplificando a implementação de deslocamentos aritméticos (`>>>` vs `>>`) e comparações (`SLT` vs `SLTU`) em contraste com a extrema verbosidade do VHDL.
	- Prática de "Hexspeak" nos *testbenches* (ex: `32'hCAFE_BABE`, `32'hDEAD_BEEF`) para criar assinaturas visuais e facilitar o rastreamento de dados nas formas de onda geradas no GTKWave.

