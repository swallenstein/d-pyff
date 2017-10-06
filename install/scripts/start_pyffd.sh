#!/bin/sh
# entrypoint for pyffd (discovery and mdx service)

if (( $(id -u) == 0 )); then
    echo "Do not start as root: ssh keys are required for the regular container user."
fi

[[ $PORT ]] || PORT='8080'

/usr/bin/pyffd -a -f --proxy \
    --log=$LOGDIR/pyffd.log \
    --error-log=$LOGDIR/pyffd.error \
    --loglevel=$LOGLEVEL \
    --frequency=$FREQUENCY \
    --port=$PORT \
    --host=0.0.0.0 \
    -p $PIDFILE \
    $PIPELINEDAEMON
