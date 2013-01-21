#!/bin/bash
#
# <> prov:specializationOf <https://github.com/timrdf/prizms/blob/master/bin/install/prizms-dependency-repos.sh>;
#    prov:wasDerivedFrom   <https://github.com/timrdf/prizms/blob/master/bin/install/project-user.sh> .
#

if [[ $# -lt 1 || "$1" == "--help" || "$1" == "-h" ]]; then
   echo "usage: `basename $0` [-n]"
   echo "  Retrieves the dependency code repositories (e.g. csv2rdf4lod-automation, lodspeakr, DataFAQs)."
   exit
fi

PRIZMS_HOME=$(cd ${0%/*} && echo ${PWD%/*})
me=$(cd ${0%/*} && echo ${PWD})/`basename $0`

for repos in git@github.com:timrdf/csv2rdf4lod-automation.git \
             git@github.com:timrdf/DataFAQs.git; do
   echo $repos
done
