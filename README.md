# 🚀 SystemVerilog Studies

Este repositório documenta minha transição e jornada de aprendizado em SystemVerilog, focando na modelagem de hardware para arquiteturas de processadores. 

## 🛠️ Setup e Execução

O repositório utiliza **Verilator** para simulação rápida e **GTKWave** para visualização de ondas. Existe um `Makefile` universal na raiz.

Para simular qualquer módulo, execute:
```bash
make sim DIR=<nome_da_pasta> MOD=<nome_do_modulo_base>
```

## 📚 Diário de Projetos e Conceitos Aprendidos

### `00_d_flip_flop`

- Conceito: O bloco fundamental de memória.

- O que aprendi de SystemVerilog aqui:
	- Uso do module para unificar a interface e implementação.
	- O tipo logic substitui as dores de cabeça do wire/reg.
	- Blocos sequenciais usam `always_ff @(posedge clk or negedge rst_n)`.
	- Importância da atribuição não-bloqueante (<=) para simular o paralelismo de registradores de hardware.

---


