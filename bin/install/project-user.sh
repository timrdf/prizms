#!/bin/bash
#
#3> <> prov:specializationOf <https://github.com/timrdf/prizms/blob/master/bin/install/project-user.sh>;
#3>    dcterms:isPartOf <http://purl.org/twc/id/software/prizms>;
#3> .

HOME=$(cd && echo ${PWD%/*}) # e.g. /Users or /home

if [[ $# -lt 1 || "$1" == "--help" || "$1" == "-h" ]]; then
   echo "usage: `basename $0` [--dryrun] [--home <dir>] <project-user-name> [[--exists]"
   exit 1
fi

dryrun='yes'
if [[ "$1" == '--dryrun' ]]; then
   dryrun=''
   shift
fi

# https://github.com/timrdf/prizms/issues/105
project_user_home="$HOME"
if [[ "$1" == '--home' ]]; then
   project_user_home="$2"
   shift 2
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
   sudo mkdir -p $project_user_home
   echo sudo /usr/sbin/useradd --home $project_user_home/$user -m $user --shell /bin/bash
   if [[ -n "$dryrun" ]]; then
        sudo /usr/sbin/useradd --home $project_user_home/$user -m $user --shell /bin/bash
   fi
   echo sudo /usr/sbin/usermod -g$user $user
   if [[ -n "$dryrun" ]]; then
        sudo /usr/sbin/usermod -g$user $user
   fi
   admin="wheel" # Could be 'admin'
   #echo sudo /usr/sbin/usermod -g$user -G$admin $user # TODO: the user needs admin/wheel
   #     sudo /usr/sbin/usermod -g$user -G$admin $user
else
   echo "INFO `basename $0`: $user already exists; not trying to add or modify." >&2
fi
