#!/usr/bin/env bash

# initialize and update the docker build environment

workdir=$(dirname $BASH_SOURCE[0])
cd $workdir

get_or_update_repo() {
    if [ -e $repodir ] ; then
        echo "pulling updates from $repodir"
        cd $repodir && git pull && cd $OLDPWD    # already cloned
    else
        echo "cloning $repodir"
        mkdir -p $repodir
        git clone $repourl $repodir        # first time
    fi
}


# --- PVZDpolman ---
repodir='install/opt/pyff'
repourl='https://github.com/rhoerbe/pyFF'
get_or_update_repo

