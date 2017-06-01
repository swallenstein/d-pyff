#!/usr/bin/env bash

main() {
    get_commandline_opts $@
    load_library_functions
    load_config
    init_sudo
    prepare_command
    exec_commands
}


get_commandline_opts() {
    while getopts ":ghHin:psS" opt; do
      case $opt in
        g) git='True';;
        H) htmlout='-H';;
        i) runopt='-it';;
        n) re='^[0-9][0-9]$'
           if ! [[ $OPTARG =~ $re ]] ; then
               echo "error: -n argument ($OPTARG) is not a number in the range frmom 02 .. 99" >&2; exit 1
           fi
           config_nr=$OPTARG;;
        p) print='True';;
        s) split='pyff';;
        S) split='xmlsectool';;
        :) echo "Option -$OPTARG requires an argument"
           exit 1;;
        *) usage; exit 0;;
      esac
    done
    shift $((OPTIND-1))
}


usage() {
    echo "usage: $0 [-h] [-H] [-i] [-s|-S]
       -g  git pull before pyff and push afterwards (use if PYFFOUT has a git repo)
       -h  print this help text
       -H  generate HTML output from metadata
       -i  interactive mode
       -n  configuration number ('<NN>' in conf<NN>.sh) (use if there is more than one)
       -p  print docker exec command on stdout
       -s  split and sign md aggregate using pyff for signing
       -S  split and sign md aggregate using xmlsectool for signing"
}


load_library_functions() {
    PROJ_HOME=$(cd $(dirname $BASH_SOURCE[0]) && pwd)
    source $PROJ_HOME/dscripts/conf_lib.sh
}


prepare_command() {
    cmd="${sudo} docker exec $runopt $CONTAINERNAME"
}


exec_commands() {
    set -e
    if [[ $git == 'True' ]]; then
        print_and_exec_command "$cmd /scripts/git_pull.sh"
    fi
    print_and_exec_command "$cmd /scripts/pyff_aggregate.sh $htmlout"
    if [[ "$split" = "pyff" ]]; then
        print_and_exec_command "$cmd /scripts/pyff_mdsplit.sh"
    fi
    if [[ "$split" = "xmlsectool" ]]; then
        print_and_exec_command "$cmd /scripts/pyff_mdsplit_xmlsectool.sh"
    fi
    if [[ $git == 'True' ]]; then
        print_and_exec_command "$cmd /scripts/git_push.sh"
    fi
}


print_and_exec_command() {
    [[ "$print" == "True" ]] && echo $@
    $@

}



main $@
