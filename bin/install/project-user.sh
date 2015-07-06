#!/bin/bash
#
#3> <> prov:specializationOf <https://github.com/timrdf/prizms/blob/master/bin/install/project-user.sh>;
#3>    dcterms:isPartOf <http://purl.org/twc/id/software/prizms>;
#3> .

HOME_BASE=$(cd && echo ${PWD%/*}) # e.g. /Users or /home
# ^^ Note, does not work when running as root.

if [[ $# -lt 1 || "$1" == "--help" || "$1" == "-h" ]]; then
   echo "usage: `basename $0` [--dryrun] [--home-base <dir>] <project-user-name> [[--exists]"
   echo "    --home-base <dir> : Directory to create user home, e.g. '/home'. (This script will creating the user directory with in <dir>."
   exit 1
fi

dryrun='yes'
if [[ "$1" == '--dryrun' ]]; then
   dryrun=''
   shift
fi

# https://github.com/timrdf/prizms/issues/105
project_user_home_base="$HOME_BASE"
if [[ "$1" == '--home-base' ]]; then
   if [[ ${#2} -gt 0 ]]; then
      project_user_home_base="$2"
      echo "accepting adjusted user home via argument: $project_user_home_base" >&2
      shift
   else
      echo "WARNING '--home-base' did not have value; ignoring and using default home: \"$project_user_home_base\"" >&2
   fi
   shift
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

if [[ -z "$exists" ]]; then
   sudo mkdir -p $project_user_home_base
   echo sudo /usr/sbin/useradd --home $project_user_home_base/$user --create-home $user --shell /bin/bash
   if [[ -n "$dryrun" ]]; then
        sudo /usr/sbin/useradd --home $project_user_home_base/$user --create-home $user --shell /bin/bash
   fi
   # undo it with (http://www.cyberciti.biz/faq/linux-remove-user-command/): 
   #    userdel -r $user
   echo sudo /usr/sbin/usermod -g$user $user
   if [[ -n "$dryrun" ]]; then
        sudo /usr/sbin/usermod -g$user $user
   fi
   #admin="wheel" # Could be 'admin'
   #echo sudo /usr/sbin/usermod -g$user -G$admin $user # TODO: the user needs admin/wheel
   #     sudo /usr/sbin/usermod -g$user -G$admin $user
else
   echo "INFO `basename $0`: $user already exists; not trying to add or modify." >&2
fi
