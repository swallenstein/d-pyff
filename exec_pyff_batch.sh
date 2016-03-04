#!/usr/bin/env bash

# get config
SCRIPTDIR=$( cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )
source $SCRIPTDIR/conf.sh

# default is to start in background; override with -i
runopt=''
while getopts ":ir" opt; do
  case $opt in
    i)
      echo "starting docker container in interactive mode"
      runopt='-it'
      docker rm $CONTAINERNAME 2>/dev/null
      ;;
  esac
done
shift $((OPTIND-1))

if [ $(id -u) -ne 0 ]; then
    sudo="sudo"
fi
${sudo} docker exec $runopt $CONTAINERNAME /start_pyff_batch.sh