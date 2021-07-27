#!/usr/bin/env bash
# Noah Bliss - 2021.07.27
# Very basic wrapper to create pseudo-interactive shell-like functionality against a specific salt minion.

if [ -z $1 ]; then read -p "Enter target minion: " minion; else minion="$1"; fi

cmd=
path=
echo "Starting OS-native shell on $minion, ctrl+c or \"exit\" to quit. Do not run interactive tasks."
while :; do
        read -r -p '> ' cmd
        echo "cmd: $cmd"
        if [ "$cmd" == "exit" ]; then exit; fi
        if echo "$cmd" | cut -f1 -d' ' | grep -q "cd"; then
                if echo "$cmd" | grep -q "^cd "; then
                        prepath="$(echo "$cmd" | sed 's/cd //')"
                        path="$(echo $prepath | sed 's/\\/\\\\/')"
                else
                        prepath=""
                        path=""
                fi
                echo "Working directory: $prepath"
        elif [ -z "$path" ]; then
                echo "running: $cmd"
                salt "$minion" cmd.run "$cmd"
        else
                echo "running: cd $path && $cmd"
                salt "$minion" cmd.run "cd $path && $cmd"
        fi
done
