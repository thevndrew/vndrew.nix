#!/usr/bin/env bash
# Zip subdirectories into cbz files
zipcbz ()
{
    for i in */;
    do
        ${1:+echo} zip -0 -r "${i%/}.cbz" "$i";
    done
}

zipcbz "$1"
