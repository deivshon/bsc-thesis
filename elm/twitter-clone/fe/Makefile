NPROCS := $(shell nproc)
MAKEFLAGS += -j$(NPROCS)

.PHONY: all build clean elm html css

all: clean
	$(MAKE) build
build: elm html css favicon
	bash ../../shared/scripts/assets-hashing.bash ./dist
clean:
	rm -rf ./dist/*

elm:
	mkdir -p ./dist
	elm make ./src/Main.elm --optimize --output=./dist/elm.js
	pnpx uglify-js@3.19.3 ./dist/elm.js --compress "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe" | pnpx uglify-js@3.19.3 --mangle --output ./dist/elm.min.js
	rm -f ./dist/elm.js
html:
	pnpx html-minifier@4.0.0 ./src/index.html --minify-js --collapse-whitespace --output ./dist/index.html
css:
	pnpm make-css
favicon:
	cp -f ../../shared/images/elm-logo.svg ./dist
