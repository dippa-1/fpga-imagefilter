GHDL=ghdl
FLAGS="--std=08"
FILTER_FILE="filter"

all:
	@$(GHDL) -a $(FLAGS) $(FILTER_FILE).vhdl $(FILTER_FILE)_testbench.vhdl
	@$(GHDL) -e $(FLAGS) $(FILTER_FILE)_testbench
	@$(GHDL) -r $(FLAGS) $(FILTER_FILE)_testbench --wave=wave.ghw --stop-time=2us

