#!/bin/sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

pids=()

cleanup() {
    for pid in "${pids[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
        fi
    done
    exit
}

trap cleanup INT

todoBe() {
    cd ./elm/todo/be
    node dist/index.js 2>&1 | awk -v color="${RED}" -v reset="${RESET}" '{print color "TDB | " $0 reset}'
}

todoBe & pids+=($!)

wait
