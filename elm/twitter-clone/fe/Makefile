NPROCS := $(shell nproc)
MAKEFLAGS += -j$(NPROCS)

.PHONY: all build clean elm elm-debug html css

all: clean-dist
	$(MAKE) build
debug: clean-dist
	$(MAKE) build-debug
build: pkgs-install
	$(MAKE) compile
build-debug: pkgs-install
	$(MAKE) compile-debug
pkgs-install:
	pnpm i
compile: elm html css favicon js
	bash ../../shared/scripts/assets-hashing.bash ./dist
compile-debug: elm-debug html css favicon js
	bash ../../shared/scripts/assets-hashing.bash ./dist
clean:
	rm -rf ./elm-stuff ./node_modules
clean-dist:
	rm -rf ./dist/*

elm:
	mkdir -p ./dist
	elm make ./src/Main.elm --optimize --output=./dist/elm.js
	pnpx uglify-js@3.19.3 ./dist/elm.js --compress "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe" | pnpx uglify-js@3.19.3 --mangle --output ./dist/elm.min.js
	rm -f ./dist/elm.js
elm-debug:
	mkdir -p ./dist
	elm make ./src/Main.elm --output=./dist/elm.js
	mv ./dist/elm.js ./dist/elm.min.js
js:
	pnpm run build-js
html:
	pnpx html-minifier@4.0.0 ./src/index.html --minify-js --collapse-whitespace --output ./dist/index.html
css:
	pnpm make-css
favicon:
	cp -f ../../shared/images/elm-logo.svg ./dist
