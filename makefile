# ==============================================================================
# SystemVerilog Studies Makefile
# ==============================================================================

# Variáveis padrão 
DIR ?= 00_d_flip_flop
MOD ?= d_flip_flop

# Caminhos dos arquivos baseados nas variáveis
SRC = $(DIR)/$(MOD).sv
TB = $(DIR)/$(MOD)_tb.sv
BIN = ./obj_dir/V$(MOD)_tb
WAVE_FILE = dump.vcd

.DEFAULT_GOAL := help
.PHONY: all help sim wave clean

all: help

help:
	@echo " "
	@echo " "
	@echo "    ███████╗██╗   ██╗    ███████╗████████╗██╗   ██╗██████╗ ██╗███████╗███████╗ "
	@echo "    ██╔════╝██║   ██║    ██╔════╝╚══██╔══╝██║   ██║██╔══██╗██║██╔════╝██╔════╝ "
	@echo "    ███████╗██║   ██║    ███████╗   ██║   ██║   ██║██║  ██║██║█████╗  ███████╗ "
	@echo "    ╚════██║╚██╗ ██╔╝    ╚════██║   ██║   ██║   ██║██║  ██║██║██╔══╝  ╚════██║ "
	@echo "    ███████║ ╚████╔╝     ███████║   ██║   ╚██████╔╝██████╔╝██║███████╗███████║ "
	@echo "    ╚══════╝  ╚═══╝      ╚══════╝   ╚═╝    ╚═════╝ ╚═════╝ ╚═╝╚══════╝╚══════╝ "
	@echo " "
	@echo "============================================================================================"
	@echo "                 SYSTEMVERILOG STUDIES - BUILD & SIMULATION SYSTEM                    "
	@echo "============================================================================================"
	@echo " "
	@echo " 🧠 PROJECT OVERVIEW"
	@echo " ──────────────────────────────────────────────────────────────────────────────────────────"
	@echo " "  
	@echo "   Target       : SystemVerilog Component Studies"
	@echo "   Simulator    : Verilator (C++ Binary Mode)"
	@echo "   Current DUT  : $(MOD) (in $(DIR)/)"
	@echo " "
	@echo " "
	@echo " 🛠️  SIMULATION WORKFLOW"
	@echo " ──────────────────────────────────────────────────────────────────────────────────────────"
	@echo " "
	@echo "   make sim DIR=<folder> MOD=<module>       Compilar e executar o testbench"
	@echo "                                            Ex: make sim DIR=00_d_flip_flop MOD=d_flip_flop"
	@echo "   make wave                                Abrir as formas de onda geradas no GTKWave"
	@echo " "
	@echo " "
	@echo " 📦 HOUSEKEEPING"
	@echo " ──────────────────────────────────────────────────────────────────────────────────────────"
	@echo " "
	@echo "   make clean                               Limpar arquivos temporários e binários"
	@echo " "
	@echo " "
	@echo "============================================================================================"
	@echo " "

sim:
	@echo ">>> 🚀 INICIANDO COMPILAÇÃO COM VERILATOR: $(MOD)"
	@echo "-------------------------------------------------------------------"
	@if [ ! -f $(SRC) ]; then echo "❌ Erro: Arquivo de design $(SRC) não encontrado!"; exit 1; fi
	@if [ ! -f $(TB) ]; then echo "❌ Erro: Testbench $(TB) não encontrado!"; exit 1; fi
	@mkdir -p obj_dir
	@# O pulo do gato: joga a saída pro build.log. Se falhar (||), ele cospe o log na tela e para.
	@verilator --binary --trace --assert -I. -I$(DIR) --top-module $(MOD)_tb $(SRC) $(TB) > obj_dir/build.log 2>&1 || (cat obj_dir/build.log && exit 1)
	@echo ">>> 🖥️  EXECUTANDO SIMULAÇÃO..."
	@echo "-------------------------------------------------------------------"
	@$(BIN)
	@echo "-------------------------------------------------------------------"
	@echo ">>> ✅ Simulação finalizada! Arquivo $(WAVE_FILE) gerado."
	@echo ">>> 💡 Para visualizar as ondas, digite: make wave"
	@echo " "

wave:
	@echo ">>> 🌊 ABRINDO GTKWAVE..."
	@if [ ! -f $(WAVE_FILE) ]; then echo "❌ Erro: $(WAVE_FILE) não encontrado. Rode 'make sim' primeiro."; exit 1; fi
	gtkwave $(WAVE_FILE) &

clean:
	@echo ">>> 🧹 LIMPANDO DIRETÓRIOS DE SIMULAÇÃO..."
	rm -rf obj_dir
	rm -f $(WAVE_FILE)
	@echo "✅ Limpeza concluída!"