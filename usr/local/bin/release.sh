#!/bin/bash

### NAME
###        release.sh - copy a file from the repository
###
### SYNOPSIS
###        release.sh <repository> <relative path> [<target_directory>]
###
### DESCRIPTION
###        Clone from the git repository and copy a specified file in it to path.
###
###        Use sudo to copy with administrative privileges.

usage() {
    echo "Usage: $0 <repository> <relative path> [<target_directory>]" 1>&2
    exit 1
}

out_error() {
    echo
    echo ERROR: $*
    echo
}

if [ $# -eq 2 ] || [ $# -eq 3 ] && [ $(basename $0) != $(basename $2) ] ; then
    repo=$1
    file=$2
    root=$3
    if [ $# -eq 2 ]; then root=/; fi
    fullpath=$root$file
    temp_dir=$(mktemp -d)
    if [ -d $temp_dir ]; then
        pushd $temp_dir > /dev/null 2>&1
        git clone -q $repo
        cd $(basename $repo .git)
        if [ -f $file ]; then
            bak=~/$(basename ${file}).bak
            if [ -f $fullpath ]; then
                cp $fullpath $bak
            fi
            if [ -f $fullpath ] && [ -f $bak ] || [ ! -f $fullpath ]; then
                sudo mkdir -p $(dirname ${fullpath})
                sudo cp $file $fullpath
            elif [ ! -f $bak ]; then
                out_error No backup exists.
            fi
            if [ ! -f $fullpath ]; then
                out_error Could not copy ${fullpath}.
            fi
        else
            out_error No $file exists.
        fi
        popd > /dev/null 2>&1
        rm -rf $temp_dir
    else
        out_error Could not create temporary directory.
    fi
elif [ $(basename $0) = $(basename $2) ]; then
    out_error Could not release $(basename $0).
else
    out_error Incorrect arguments.
    usage
fi
