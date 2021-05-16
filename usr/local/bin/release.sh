#!/bin/bash

### NAME
###        release.sh - download a file from the git repository
###
### SYNOPSIS
###        release.sh <user> <repo> <branch> <relative path> [<target_directory>]
###
### DESCRIPTION
###        Download a file from the git repository. The repository is specified by
###        user name, repository name, and branch name.
###
###        Use sudo to copy with administrative privileges.

provider=github
status=0

usage() {
    echo "Usage: $0 <user> <repo> <branch> <relative path> [<target_directory>]" 1>&2
}

out_error() {
    # display in red text.
    echo -e "\e[0;91m"ERROR: $*"\e[0m"
    status=1
}

if [ $# -eq 4 ] || [ $# -eq 5 ] && [ $(basename $0) != $(basename $4) ] ; then
    user=$1
    repo=$2
    branch=$3
    file=$4
    root=$5
    [ $# -eq 4 ] && root=/
    [ $provider = github ] && url=https://github.com/$user/$repo/archive/refs/heads/$branch.tar.gz
    fullpath=$root$file
    temp_dir=$(mktemp -d)
    if [ -d $temp_dir ]; then
        pushd $temp_dir > /dev/null 2>&1
        curl -Ls $url | tar -zx
        cd $repo-$branch
        if [ -f $file ]; then
            bak=~/$(basename $file).bak
            [ -f $fullpath ] && cp $fullpath $bak
            if [ -f $fullpath ] && [ -f $bak ] || [ ! -f $fullpath ]; then
                sudo mkdir -p $(dirname $fullpath)
                sudo cp $file $fullpath
            elif [ ! -f $bak ]; then
                out_error No backup exists.
            fi
            [ ! -f $fullpath ] && out_error Could not copy $fullpath.
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
exit status
