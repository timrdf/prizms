#!/bin/bash
#
# <> prov:specializationOf <> .
#

if [[ $# -lt 1 || "$1" == "--help" || "$1" == "-h" ]]; then
   echo "usage: `basename $0` <project-user-name>"
   exit 1
fi

user="$1"

   echo sudo cat /etc/passwd | cut -d: -f1 | grep $user
exists=`sudo cat /etc/passwd | cut -d: -f1 | grep $user`

if [[ -z $exists ]]; then
   admin="wheel" # Could be 'admin'
   echo sudo /usr/sbin/useradd $user
        sudo /usr/sbin/useradd $user
   echo sudo /usr/sbin/usermod -g$user $user
        sudo /usr/sbin/usermod -g$user $user
   #echo sudo /usr/sbin/usermod -g$user -G$admin $user
   #     sudo /usr/sbin/usermod -g$user -G$admin $user
else
   "WARNING `basename $0`: $user already exists; not trying to add or modify." >&2
fi
