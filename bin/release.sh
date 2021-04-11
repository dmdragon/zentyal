#!/bin/bash

### .SYNOPSIS
###     Copy a file from the repository
###
### .DESCRIPTION
###     Clone from the git repository and copy a specified file in it to path.
###
###     Use sudo to copy with administrative privileges.
###
### .PARAMETER r
###     Repository
###
### .PARAMETER p
###     Relative path to a file in the repository

usage() {
    echo "Usage: $0 -r <repository> -p <path>" 1>&2
    exit 1
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
        bak=~/$(basename $file).bak
        cp /$file $bak
        if [ -f $bak ]; then
            sudo mkdir -p $(dirname /$file)
            sudo cp $file /$file
        else
            echo No backup exists.
        fi
        if [ ! -f /$file ]; then
            echo No /$file exists.
        fi
        popd
        rm -rf $temp_dir
    else
        echo Could not create temporary directory.
    fi
else
    if [ -z $repo ]; then
        echo No repository.
    fi
    if [ -z $file ]; then
        echo No path.
    fi
fi