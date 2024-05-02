#!/usr/bin/env bash

# Check if the script is called with an argument
if [ $# -lt 1 ]; then
    echo "Usage: $0 <~/path/to/streams.yml>"
    exit 1
fi

stream=$(yq -r '.streams | keys | .[]' "$1" | fzf)

pid_of_downloader=$(ps -ef | grep dl_stream | grep $stream | tr -s " " | cut -d" " -f2)
if [ -z "$pid_of_downloader" ]; then
    echo No PID found for that stream!
else
    echo Killing processes with parent PID $pid_of_downloader
    pkill -9 -P $pid_of_downloader
    kill $pid_of_downloader
fi
