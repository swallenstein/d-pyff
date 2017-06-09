#!/usr/bin/env bash

# make ssh-keys for github deploy keys

main() {
    get_commandline_opts "$@"
    block_root
    test_required_env_vars
    generate_sshkey
    create_repo_host_alias
    register_sshkey
}


get_commandline_opts() {
    while getopts ":hn:" opt; do
      case $opt in
        n) keyname=$OPTARG
        :) echo "Option -$OPTARG requires an argument"; exit 1;;
        *) usage; exit 1;;
      esac
    done
}


usage() {
    echo "Generate ssh-keys and test
       usage: $0 [-h] [-n keyname]
       -h  print this help text
       -n  suffix for the key file name (used for multiple ssh keys with git)
       "
}


block_root() {
    if (( $(id -u) == 0 )); then
        echo "Do not start as root: ssh keys are required for the regular container user."
    fi
}


test_required_env_vars() {
    [[ -z $MDFEED_HOST ]] && echo "MDFEED_HOST not set" && exit 1
    [[ -z $MDFEED_REPO ]] && echo "MDFEED_REPO not set" && exit 1
}


generate_sshkey() {
    if [[ ! -e ~/.ssh/id_ed25519 ]]; then
        ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_${keyname} -N ''
    fi
}


create_repo_host_alias() {
    if [[ ! -z ${keyname+x} ]]; then
        cat > ~/.ssh/config << EOT

Host ${keyname}
Hostname $MDFEED_HOST
IdentityFile /home/username/.ssh/id_ed25519_${keyname}

EOT
    fi
    chmod 400 /home/username/.ssh/config
    git clone  git@repo1:owner/repo1.git
}


register_sshkey() {
    echo "created new public key - register with $MDFEED_HOST/$MDFEED_REPO:"
    if [[ -e ~/.ssh/id_ed25519_${keyname}.pub ]]; then
        cat ~/.ssh/id_ed25519_${keyname}.pub
    fi

    echo "After registration: test connection with:"
    echo "ssh -T $MDFEED_SSHUSER@$MDFEED_HOST"
}


main "$@"