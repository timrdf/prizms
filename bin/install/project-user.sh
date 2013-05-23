#!/bin/bash
#
# <> prov:specializationOf <https://github.com/timrdf/prizms/blob/master/bin/install/project-user.sh> .
#

HOME=$(cd && echo ${PWD%/*}) # e.g. /Users or /home

if [[ $# -lt 1 || "$1" == "--help" || "$1" == "-h" ]]; then
   echo "usage: `basename $0` <project-user-name> [[--exists]"
   exit 1
fi

user="$1"

   echo sudo cat /etc/passwd | cut -d: -f1 | grep $user
exists=`sudo cat /etc/passwd | cut -d: -f1 | grep $user`

if [[ "$2" == "--exists" ]]; then
   if [[ -z $exists ]]; then
      echo "no"
   else
      echo "yes"
   fi
   exit
fi

if [[ -z $exists ]]; then
   admin="wheel" # Could be 'admin'
   echo sudo /usr/sbin/useradd -d $HOME/$user -m $user
        sudo /usr/sbin/useradd -d $HOME/$user -m $user
   echo sudo /usr/sbin/usermod -g$user $user
        sudo /usr/sbin/usermod -g$user $user
   #echo sudo /usr/sbin/usermod -g$user -G$admin $user # TODO: the user needs admin/wheel
   #     sudo /usr/sbin/usermod -g$user -G$admin $user
else
   echo "INFO `basename $0`: $user already exists; not trying to add or modify." >&2
fi
