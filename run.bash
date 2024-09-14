#!/bin/bash

red="\033[0;31m"
green="\033[0;32m"
yellow="\033[0;33m"
blue="\033[0;34m"

reset="\033[0m"

todoBeDir="$(realpath ./elm/todo/be)"
todoBeDist="$(realpath $todoBeDir/dist)"
todoFeDir="$(realpath ./elm/todo/fe)"
todoFeDist="$(realpath $todoFeDir/dist)"
twitterCloneBeDir="$(realpath ./elm/twitter-clone/be)"
twitterCloneBeDist="$(realpath $twitterCloneBeDir/dist)"
twitterCloneFeDir="$(realpath ./elm/twitter-clone/fe)"
twitterCloneFeDist="$(realpath $twitterCloneFeDir/dist)"

cp -f $(which unbuffer) ./bsc-thesis-unbuffer
unbufferCommand="$(realpath ./bsc-thesis-unbuffer)"

declare -a runAllPids

cleanup() {
    ps -aux | grep bsc-thesis-unbuffer | awk '{print $2}' | xargs kill -9 2>/dev/null

    if [ ! -z "$1" ]; then
        return
    fi

    for pid in "${runAllPids[@]}"; do
        kill $pid 2>/dev/null
    done

    printf "\n%s\n" "------------------------ EXIT"
    exit
}

trap cleanup INT

todoBe() {
    cd "$todoBeDir" || return 1
    "$unbufferCommand" node "$todoBeDist"/index.js 2>&1 | awk -v color="${red}" -v reset="${reset}" '{print color "TDB | " $0 reset}'
}

todoFe() {
    "$unbufferCommand" python -m http.server --directory "$todoFeDist" 8000 2>&1 | awk -v color="${green}" -v reset="${reset}" '{print color "TDF | " $0 reset}'
}

twitterCloneBe() {
    cd "$twitterCloneBeDir" || return 1
    "$unbufferCommand" node "$twitterCloneBeDist"/index.js 2>&1 | awk -v color="${yellow}" -v reset="${reset}" '{print color "TCB | " $0 reset}'
}

twitterCloneFe() {
    "$unbufferCommand" python -m http.server --directory "$twitterCloneFeDist" 8001 2>&1 | awk -v color="${blue}" -v reset="${reset}" '{print color "TCF | " $0 reset}'
}

notificationId=$(notify-send "Starting all BSC Thesis services" -p)
runAll() {
    local sleepFlag="$1"
    local notificationId="$2"

    trap "return" USR1

    if [ "$sleepFlag" = "sleepAtStart" ]; then
        sleep 2.5
        notify-send -r "$notificationId" "Restarting all BSC Thesis services"
        printf "%s\n" "------------------------ RESTART"
    else
        printf "%s\n" "------------------------ START"
    fi

    todoBe &
    todoFe &
    twitterCloneBe &
    twitterCloneFe &
}

killSleepingRunAlls() {
    for pid in "${runAllPids[@]}"; do
        if ! kill -0 $pid 2>/dev/null; then
            runAllPids=("${runAllPids[@]/$pid}")
        else
            kill -s USR1 "$pid"
        fi
    done
}

runAll &

while IFS= read -r line; do
    cleanup 1
    killSleepingRunAlls

    runAll sleepAtStart "$notificationId" &
    runAllPids+=($!)
done < <(inotifywait "$todoBeDist" "$todoFeDist" "$twitterCloneBeDist" "$twitterCloneFeDist" -me create 2>/dev/null)

cleanup
