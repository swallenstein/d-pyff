#!/bin/sh

CONF_FILE=/etc/eToken.conf
ETOKEN_RPM=SafenetAuthenticationClient-9.1.7-0.i386.rpm
VERSION=9.1.7-0
need_apply=0
lang=pt-BR

set_lang()
{
  INSTALLED_LANG=`grep "LanguageId=" $CONF_FILE`
  if [ "$INSTALLED_LANG" != "LanguageId=$lang" ] ; then
    echo "Installing Language code ${lang}."
    cat ${CONF_FILE} | sed -e "s/LanguageId=[a-z][a-z]-[A-Z][A-Z]/LanguageId=${lang}/" > /tmp/eToken.conf.new
    mv /tmp/eToken.conf.new ${CONF_FILE}
    need_apply=1
  fi
  return 0
}

check_root ()
{
  if [ "$UID" != "0" ] ; then
    echo "Please run this script as root!"
    exit 1
  fi
  return 0
}


restart_SACMonitor ()
{
  echo "logout and login to apply changes"
#  if ps -e | grep SACMonitor >& /dev/null ; then
#    /usr/bin/killall SACMonitor >& /dev/null
#    users=`who | cut -d' ' -f1 | uniq`
#    for user in $users
#    do
#      su - $user -c "DISPLAY=:0.0  /usr/bin/SACMonitor & >/dev/null" 
#    done
#  fi
#  return 0
}

check_root
if ! rpm -q SafenetAuthenticationClient-9.1.7-0 > /dev/null ; then
  if [ -f $ETOKEN_RPM ] ; then
    if ! rpm -Uh ${ETOKEN_RPM} ; then
      echo "Error installing rpm."
      exit 1
    fi
    need_apply=1
  else
    echo "installation file $ETOKEN_RPM missing."
    exit 1
  fi
fi

set_lang
if [ $need_apply = 1 ] ; then
  restart_SACMonitor
fi



	
	
