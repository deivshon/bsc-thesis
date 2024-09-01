NPROCS := $(shell nproc)
MAKEFLAGS += -j$(NPROCS)

.PHONY: all clean todo twitter-clone vax-graphs todo-clean twitter-clone-clean vax-graphs-clean

all: todo twitter-clone vax-graphs
clean: todo-clean twitter-clone-clean vax-graphs-clean

todo:
	$(MAKE) -C ./todo
twitter-clone:
	$(MAKE) -C ./twitter-clone
vax-graphs:
	$(MAKE) -C ./vax-graphs

todo-clean:
	$(MAKE) -C ./todo clean
twitter-clone-clean:
	$(MAKE) -C ./twitter-clone clean
vax-graphs-clean:
	$(MAKE) -C ./vax-graphs clean
