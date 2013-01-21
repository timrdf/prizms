#!/bin/bash
#
# <> prov:specializationOf <https://github.com/timrdf/prizms/blob/master/bin/install/prizms-dependency-repos.sh>;
#    prov:wasDerivedFrom   <https://github.com/timrdf/prizms/blob/master/bin/install/project-user.sh> .
#

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
   echo "usage: `basename $0` [-n]"
   echo "  Retrieves the dependency code repositories (e.g. csv2rdf4lod-automation, lodspeakr, DataFAQs)."
   exit
fi

PRIZMS_HOME=$(cd ${0%/*/*} && echo ${PWD%/*})
me=$(cd ${0%/*} && echo ${PWD})/`basename $0`

if [ ! -e $PRIZMS_HOME/repos ]; then
   mkdir -p $PRIZMS_HOME/repos
fi

pushd $PRIZMS_HOME/repos &> /dev/null
   for repos in git://github.com:timrdf/csv2rdf4lod-automation.git \
                git://github.com:timrdf/DataFAQs.git; do
      echo git clone $repos
           git clone $repos
   done
popd
