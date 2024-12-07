NPROCS := $(shell nproc)
MAKEFLAGS += -j$(NPROCS)

.PHONY: all clean thesis slides elm thesis-clean slides-clean elm-clean

all: thesis elm slides
clean: thesis-clean elm-clean slides-clean

thesis:
	$(MAKE) -C ./thesis
slides:
	$(MAKE) -C ./slides
elm:
	$(MAKE) -C ./elm

thesis-clean:
	$(MAKE) -C ./thesis clean
slides-clean:
	$(MAKE) -C ./slides clean
elm-clean:
	$(MAKE) -C ./elm clean
