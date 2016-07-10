#!/usr/bin/env bash

# initialize and update the docker build environment

workdir=$(dirname $BASH_SOURCE[0])
cd $workdir

get_or_update_repo() {
    if [ -e $repodir ]; then
        echo "pulling updates from $repodir"
        cd $repodir && git pull && cd $OLDPWD    # already cloned
    else
        echo "cloning $repodir"
        mkdir -p $repodir
        git clone $repourl $repodir        # first time
    fi
}


# --- pyFF ---
repodir='install/opt/pyff'
repourl='https://github.com/rhoerbe/pyFF'
get_or_update_repo

# --- XMLSECTOOL ---
repodir='xmlsectool-2'
cd $workdir/install/opt/
if [ ! -e $repodir ]; then
    echo "downloading xmlsectool-2.0.0-beta-1-bin.zip"
    wget https://shibboleth.net/downloads/tools/xmlsectool/2.0.0-beta-1/xmlsectool-2.0.0-beta-1-bin.zip
    unzip xmlsectool-2.0.0-beta-1-bin.zip
    ln -s xmlsectool-2.0.0-beta-1 $repodir
    rm xmlsectool-2.0.0-beta-1-bin.zip
fi
