#!/usr/bin/env bash

while getopts ":hin:s" opt; do
  case $opt in
    i)
      runopt='-it'
      ;;
    n)
      re='^[0-9][0-9]$'
      if ! [[ $OPTARG =~ $re ]] ; then
         echo "error: -n argument ($OPTARG) is not a number in the range frmom 02 .. 99" >&2; exit 1
      fi
      config_nr=$OPTARG
      ;;
    s)
      split='True'
      ;;
    :)
      echo "Option -$OPTARG requires an argument"
      exit 1
      ;;
    *)
      echo "usage: $0 [-h] [-i] [-s]
   -h  print this help text
   -i  interactive mode
   -n  configuration number ('<NN>' in conf<NN>.sh)
   -s  split and sign md aggregate"
      exit 0
      ;;
  esac
done
shift $((OPTIND-1))

# get config
SCRIPTDIR=$(cd $(dirname $BASH_SOURCE[0]) && pwd)
source $SCRIPTDIR/conf${config_nr}.sh

if [ $(id -u) -ne 0 ]; then
    sudo="sudo"
fi
${sudo} docker exec $runopt $CONTAINERNAME /pyff_aggregate.sh
if [ "$split" = "True" ]; then
    ${sudo} docker exec $runopt $CONTAINERNAME /pyff_mdsplit.sh
fi