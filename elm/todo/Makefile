NPROCS := $(shell nproc)
MAKEFLAGS += -j$(NPROCS)

.PHONY: all clean fe be fe-clean be-clean

all: fe be
clean: fe-clean be-clean

fe:
	$(MAKE) -C ./fe
be:
	$(MAKE) -C ./be

fe-clean:
	$(MAKE) -C ./fe clean
be-clean:
	$(MAKE) -C ./be clean
