#!/bin/bash
#
#3> <> prov:specializationOf <https://github.com/timrdf/prizms/blob/master/bin/install/paths.sh>;
#3>    prov:wasDerivedFrom <https://github.com/timrdf/DataFAQs/blob/master/bin/df-situate-paths.sh> .
#
# Usage:
#   export PATH=$PATH`$DATAFAQS_HOME/bin/df-situate-paths.sh`
#   (can be repeated indefinitely, once paths are in PATH, nothing is returned.)

HOME=$(cd ${0%/*/*} && echo ${PWD%/*})
me=$(cd ${0%/*} && echo ${PWD})/`basename $0`

if [ "$1" == "--help" ]; then
   echo "`basename $0` [--help]"
   echo
   echo "Return the shell paths needed for Prizms scripts to run."
   echo "Set them by executing:"
   echo
   echo "    export PATH=\$PATH\`$me\`"
   echo $HOME
   exit
fi

missing=""

if [ ! `which prizms-dependency-repos.sh` ]; then
   missing=":"
   missing=$missing$HOME/bin/install
fi

#if [[ ! `which tdbloader` && -d "$TDBROOT" ]]; then
#   if [ ${#missing} -gt 0 ]; then
#      missing=$missing":"
#   fi
#   missing=$missing$TDBROOT/bin
#fi

#if [ ! `which pcurl.sh` ]; then export PATH=$PATH:$DATAFAQS_HOME/bin/util
#   if [ ${#missing} -gt 0 ]; then
#      missing=$missing":"
#   fi
#   missing=$missing$DATAFAQS_HOME/bin/util
#fi
#
#if [ ! `which vload` ]; then
#   if [ ${#missing} -gt 0 ]; then
#      missing=$missing":"
#   fi
#   missing=$missing$DATAFAQS_HOME/bin/util/virtuoso
#fi

if [ -e $HOME/repos/csv2rdf4lod-automation/bin/util/cr-situate-paths.sh ]; then
   missing=$missing`$HOME/repos/csv2rdf4lod-automation/bin/util/cr-situate-paths.sh`
fi

if [ -e $HOME/repos/DataFAQs/bin/df-situate-paths.sh ]; then
   missing=$missing`$HOME/repos/DataFAQs/bin/df-situate-paths.sh`
fi

echo $missing

#for path in `echo ${PATH//://  }`; do
#   echo $path
#done
