NPROCS := $(shell nproc)
MAKEFLAGS += -j$(NPROCS)

.PHONY: all build clean elm html css

all: clean
	$(MAKE) build
build: 
	true
clean:
	rm -rf ./dist
