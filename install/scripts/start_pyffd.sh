#!/bin/sh
# entrypoint for pyffd (discovery and mdx service)

if (( $(id -u) == 0 )); then
    echo "Do not start as root: ssh keys are required for the regular container user."
    exit 1
fi

[[ "$LOGDIR" ]] || LOGDIR='/var/log'
[[ "$LOGLEVEL" ]] || LOGLEVEL='INFO'
[[ "$FREQUENCY" ]] || FREQUENCY=600
[[ "$PORT" ]] || PORT='8080'
[[ "$PIDFILE" ]] || PIDFILE='/var/log/pyffd.pid'

/usr/bin/pyffd -a -f --proxy \
    --error-log=$LOGDIR/pyffd.error \
    --frequency=$FREQUENCY \
    --host=0.0.0.0 \
    --log=$LOGDIR/pyffd.log \
    --loglevel=$LOGLEVEL \
    --port=$PORT \
    -p $PIDFILE \
    $PIPELINEDAEMON
