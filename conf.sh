#!/usr/bin/env bash

# configure container
export IMGID='3'  # range from 2 .. 99; must be unique
export IMAGENAME="r2h2/pyff${IMGID}"
export CONTAINERNAME="${IMGID}pyffTestWpv"
export CONTAINERUSER="pyff${IMGID}"   # group and user to run container
export CONTAINERUID="800${IMGID}"   # gid and uid for CONTAINERUSER
export ENVSETTINGS="
    -e FREQUENCY=600
    -e LOGDIR=/var/log
    -e LOGLEVEL=INFO
    -e PIDFILE=/var/log/pyffd.pid
    -e PIPELINEBATCH=/etc/pyff/md_aggregator.fd
    -e PIPELINEDAEMON=/etc/pyff/mdx_disco.fd
"
export NETWORKSETTINGS="
    -p 7080:8080
    -p 7443:8443
    --net http_proxy
    --ip 10.1.1.${IMGID}
"
export VOLROOT="/docker_volumes/$CONTAINERNAME"  # container volumes on docker host
export VOLMAPPING="
    -v $VOLROOT/etc/pki:/etc/pki:Z
    -v $VOLROOT/etc/pyff:/etc/pyff:Z
    -v $VOLROOT/var/log:/var/log:Z
    -v $VOLROOT/var/md_agg:/var/md_agg:Z
    -v $VOLROOT/var/md_feed:/var/md_feed:Z
    -v $VOLROOT/var/md_source:/var/md_source:Z
"
export STARTCMD='/start_pyffd.sh'

# first start: create user/group/host directories
if ! id -u $CONTAINERUSER &>/dev/null; then
    groupadd -g $CONTAINERUID $CONTAINERUSER
    adduser -M -g $CONTAINERUID -u $CONTAINERUID $CONTAINERUSER
fi
if [ -d $VOLROOT/var/log/$CONTAINERNAME ]; then
    mkdir -p $VOLROOT/var/log
    chown $CONTAINERUSER:$CONTAINERUSER $VOLROOT/var/log
fi
# create dir with given user if not existing, relative to $HOSTVOLROOT
function chkdir {
    dir=$1
    user=$2
    mkdir -p "$VOLROOT/$dir"
    chown -R $user:$user "$VOLROOT/$dir"
}
chkdir etc/pki $CONTAINERUSER
chkdir etc/pyff $CONTAINERUSER
chkdir var/log $CONTAINERUSER
chkdir var/md_agg $CONTAINERUSER
chkdir var/md_feed $CONTAINERUSER
chkdir var/md_source $CONTAINERUSER
