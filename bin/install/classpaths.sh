#!/bin/bash
#
#3> <> prov:specializationOf <https://github.com/timrdf/prizms/blob/master/bin/install/classpaths.sh>;
#3>    prov:wasDerivedFrom <https://github.com/timrdf/prizms/blob/master/bin/install/paths.sh> .
#
# Usage:
#   export PATH=$PATH`$DATAFAQS_HOME/bin/df-situate-paths.sh`
#   (can be repeated indefinitely, once paths are in PATH, nothing is returned.)

HOME=$(cd ${0%/*/*} && echo ${PWD%/*})
me=$(cd ${0%/*} && echo ${PWD})/`basename $0`

if [ "$1" == "--help" ]; then
   echo "`basename $0` [--help]"
   echo
   echo "Return the classpaths needed for Prizms scripts to run."
   echo "Set them by executing:"
   echo
   echo "    export CLASSPATH=\$CLASSPATH\`$me\`"
   exit
fi

missing=""

# TODO: if/when Prizms has its own jars, include them here:

# Java dependencies
#for jar in `find $HOME/lib -name "*.jar"`; do
#   if [[ $CLASSPATH != *`basename $jar`* ]]; then
#      if [ "$verbose" == "true" ]; then
#         echo "`basename $jar` not in classpath; adding $HOME/$jar"
#      fi
#      missing=$missing:$jar
#   fi
#done


if [ -e $HOME/repos/csv2rdf4lod-automation/bin/util/cr-situate-classpaths.sh ]; then
   missing=$missing`$HOME/repos/csv2rdf4lod-automation/bin/util/cr-situate-classpaths.sh`
fi

# TODO: if/when DataFAQs has its own jars, include them here:

#if [ -e $HOME/repos/DataFAQs/bin/df-situate-paths.sh ]; then
#   missing=$missing`$HOME/repos/DataFAQs/bin/df-situate-paths.sh`
#fi

echo $missing