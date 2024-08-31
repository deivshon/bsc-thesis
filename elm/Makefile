NPROCS := $(shell nproc)
MAKEFLAGS += -j$(NPROCS)

.PHONY: all clean todo twitter-clone vax-graphs todo-clean twitter-clone-clean vax-graphs-clean

all: todo twitter-clone vax-graphs
clean: todo-clean twitter-clone-clean vax-graphs-clean

todo:
	make -C ./todo
twitter-clone:
	make -C ./twitter-clone
vax-graphs:
	make -C ./vax-graphs

todo-clean:
	make -C ./todo clean
twitter-clone-clean:
	make -C ./twitter-clone clean
vax-graphs-clean:
	make -C ./vax-graphs clean
