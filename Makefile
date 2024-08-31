NPROCS := $(shell nproc)
MAKEFLAGS += -j$(NPROCS)

.PHONY: all clean thesis elm thesis-clean elm-clean

all: thesis elm
clean: thesis-clean elm-clean

thesis:
	$(MAKE) -C ./thesis
elm:
	$(MAKE) -C ./elm

thesis-clean:
	$(MAKE) -C ./thesis clean
elm-clean:
	$(MAKE) -C ./elm clean
