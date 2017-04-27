#!/bin/sh
# entrypoint for pyffd (discovery and mdx service)

if (( $(id -u) == 0 )); then
    echo "Do not start as root: ssh keys are required for the regular container user."
fi


/usr/bin/pyffd -a -f --proxy \
    --log=$LOGDIR/pyffd.log \
    --error-log=$LOGDIR/pyffd.error \
    --loglevel=$LOGLEVEL \
    --frequency=$FREQUENCY \
    -H0.0.0.0 \
    -p $PIDFILE \
    $PIPELINEDAEMON
