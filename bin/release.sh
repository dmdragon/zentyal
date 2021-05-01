#!/bin/bash

### NAME
###        release.sh - copy a file from the repository
###
### SYNOPSIS
###        release.sh -r repository -p path
###
### DESCRIPTION
###        Clone from the git repository and copy a specified file in it to path.
###
###        Use sudo to copy with administrative privileges.
###
### OPTIONS
###        -r repository
###               Specify the URL for the repoistory.
###
###        -p path
###               Spacify the relative path to a file in the repository.

usage() {
    echo "Usage: $0 -r <repository> -p <path>" 1>&2
    exit 1
}

out_error() {
    echo
    echo ERROR: $*
    echo
}

while getopts r:p:h OPT; do
    case $OPT in
        r)  repo=$OPTARG
            ;;
        p)  file=$OPTARG
            ;;
        h)  usage
            ;;
        \?) usage
            ;;
    esac
done

if [ $repo ] && [ $file ]; then
    temp_dir=$(mktemp -d)
    if [ -d $temp_dir ]; then
        pushd $temp_dir
        git clone $repo
        cd $(basename $repo .git)
        if [ -f $file ]; then
            bak=~/$(basename ${file}).bak
            if [ -f /$file ]; then
                cp /$file $bak
            fi
            if [ -f /$file ] && [ -f $bak ] || [ ! -f /$file ]; then
                sudo mkdir -p $(dirname /${file})
                sudo cp $file /$file
            elif [ ! -f $bak ]; then
                out_error No backup exists.
            fi
            if [ ! -f /$file ]; then
                out_error Could not copy /${file}.
            fi
        else
            out_error No $file exists.
        fi
        popd
        rm -rf $temp_dir
    else
        out_error Could not create temporary directory.
    fi
else
    echo
    if [ -z $repo ]; then
        echo ERROR: No repository.
    fi
    if [ -z $file ]; then
        echo ERROR: No path.
    fi
    echo
    usage
fi