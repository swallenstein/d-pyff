# deploy pyFF using docker 

A docker image for running a pyFF instance in either of 2 modes:
    1. daemon mode (mdx service and idp discovery as implemented by pyff/mdx).
    2. batch mode (metadata aggregator as implemented by pyff/md).

The image produces immutable containers, i.e. a container can be removed and re-created
any time without loss of data, because data is stored on mounted volumes.

The image is prepared for for metadata signature creation with pkcs#11 devices.

## Build the docker image
1. adapt conf.sh
2. run build.sh: 

   To run multiple pyff containers on the same system you need to create separate conf.sh files
   and build separate images:
   E.g. to create pyff container instance 3:
   a) create a file conf3.sh, and set the IMGID=3; and
   b) build the container with the -n option, e.g. `build.sh -n 3`
   c) run the container with the -n option, e.g. `run.sh -n 3`


## Usage: pyffd
Initialize mounted volumes with sample data (optional):
    
    run.sh -i init_sample.sh

Configure pyff: 
    Copy a default file to md_aggregate_sign.fd and edit the settings.


Start pyffd as discovery and mdx service:
Configure env variables (in conf.sh):
    FREQUENCY
    LOGLEVEL 
    PIDFILE
    PIPELINEDAEMON

    run.sh
    curl http://localhost:8080
    
Take care of appropriate port mapping and/or proxying

Documentation: See http://leifj.github.io/pyFF


## Usage: pyFF/batch mode
Preconditiona: 
* The container needs to be running already (usually as a pyffd). 
* The `docker run` command needs to contain:
    * 3 enviroment variables: LOGFILE, LOGLEVEL and PIPELINE;
    * The volumes referenced in LOGFILE and PIPELINE must be mounted to the container;
    * pyff shall not be run as root, but the user defined with CONTAINERUSER and CONTAINERUID in
      conf.sh
Start pyff:
 
    exec_pyff_batch.sh 

Sample entry for /etc/crontab to run pyff every hour:

    29 *  *  *  *  root /docker_images/pyff/exec_pyff_batch.sh -n 3 2>&1 > /var/log/exec_pyff_batch-3.log 
 
    
## HSM/pyFF config

Config the key name in md_aggregate_sign.fd to match the key name on the HSM.
(See the line with 'sign -> key')

Provide the PYKCS11PIN env variable if using the HSM
