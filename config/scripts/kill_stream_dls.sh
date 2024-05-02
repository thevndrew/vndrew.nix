#!/bin/sh
pgrep -f ./dl_stream | xargs kill --verbose
pgrep -f yt-dlp | xargs kill --verbose
