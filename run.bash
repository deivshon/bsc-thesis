#!/bin/bash

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"

RESET="\033[0m"

pids=()

cleanup() {
    for pid in "${pids[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
        fi
    done

    printf "\n%s\n" "------------------------ EXIT"
    exit
}

trap cleanup INT

todoBe() {
    cd ./elm/todo/be || return 1
    unbuffer node ./dist/index.js 2>&1 | awk -v color="${RED}" -v reset="${RESET}" '{print color "TDB | " $0 reset}'
}

todoFe() {
    unbuffer python -m http.server --directory ./elm/todo/fe/dist 8000 2>&1 | awk -v color="${GREEN}" -v reset="${RESET}" '{print color "TDF | " $0 reset}'
}

twitterCloneBe() {
    cd ./elm/twitter-clone/be || return 1
    unbuffer node ./dist/index.js 2>&1 | awk -v color="${YELLOW}" -v reset="${RESET}" '{print color "TCB | " $0 reset}'
}

printf "%s\n" "------------------------ START"

todoBe & pids+=($!)
todoFe & pids+=($!)
twitterCloneBe & pids+=($!)

wait
