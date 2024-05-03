#!/usr/bin/env bash

# Check if the script is called with an argument
if [ $# -lt 2 ]; then
    echo "Usage: $0 <~/path/to/streams.yml> <path/to/output/dir> [-i]"
    exit 1
fi

set -e
set +o errexit
set +o nounset
set +o pipefail

echo Entering ouput directory \""$2"\"
pushd "$2"

download_stream() {
    nohup rip_stream_helper "$1" "$2" &> "$2".log &
}

yq_filter=".streams | keys | .[]"

# interactive case
if [ $# -gt 2 ]
then
    stream=$(yq -r "$yq_filter" "$1" | fzf)    

    echo "Starting downloader for $stream"
    download_stream "$1" "$stream"
else
    streams=()
    while IFS='' read -r line;
    do
        streams+=("$line");
    done < <(yq -r "$yq_filter" "$1")
    
    for stream in "${streams[@]}";
    do
        echo "Starting downloader for $stream"
	download_stream "$1" "$stream"
    done;
fi
popd

