#!/usr/bin/env bash

# Initialize and update the docker build environment
# Providing resources before starting docker build provides better control about updates
# and can speed up the build process.

update_pkg="False"

while getopts ":huU" opt; do
  case $opt in
    u)
      update_pkg="True"
      ;;
    U)
      update_pkg="False"
      ;;
    *)
      echo "usage: $0 [-u] [-U]
   -u  update git repos in docker build context
   -U  do not update git repos in docker build context (default)

   To update packages delivered as tar-balls just delete them from install/opt
   "
      exit 0
      ;;
  esac
done
shift $((OPTIND-1))

BUILDDIR=$(cd $(dirname $BASH_SOURCE[0]) && pwd)
source $BUILDDIR/dscripts/conf_lib.sh  # load library functions
cd $BUILDDIR


# --- pyXMLSecurity ---
repodir='install/opt/pyXMLSecurity'
repourl='https://github.com/rhoerbe/pyXMLSecurity'
get_or_update_repo

# --- pyFF/branch=mdsplit ---
repodir='install/opt/pyff'
repourl='https://github.com/identinetics/pyFF'
get_or_update_repo
echo "changing pyff branch to mdsplit"
cd $repodir && git checkout mdsplit && cd $OLDPWD

# --- XMLSECTOOL ---
repodir='xmlsectool-2'
version='2.0.0'
cd "$BUILDDIR/install/opt/"
if [ ! -e $repodir ]; then
    echo "downloading xmlsectool-${version}-bin.zip"
    wget "https://shibboleth.net/downloads/tools/xmlsectool/${version}/xmlsectool-${version}-bin.zip"
    unzip "xmlsectool-${version}-bin.zip"
    ln -s "xmlsectool-${version}" $repodir
    rm "xmlsectool-${version}-bin.zip"
fi
