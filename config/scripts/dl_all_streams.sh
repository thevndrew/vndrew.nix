#!/usr/bin/env bash

# Check if the script is called with an argument
if [ $# -lt 2 ]; then
    echo "Usage: $0 <~/path/to/streams.yml> <path/to/output/dir>"
    exit 1
fi

set -e

streams=($(yq -r '.streams | keys | .[]' "$1"))

echo Entering ouput directory \"$2\"
pushd $2

for stream in "${streams[@]}";
do
    nohup dl_stream $1 $stream &> $stream.log &
done;
popd

