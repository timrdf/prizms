#!/bin/bash
#
#3> <> prov:specializationOf <https://github.com/timrdf/prizms/blob/master/bin/install/paths.sh>;
#3>    prov:wasDerivedFrom <https://github.com/timrdf/DataFAQs/blob/master/bin/df-situate-paths.sh>;
#3>    dcterms:isPartOf <http://purl.org/twc/id/software/prizms>;
#3> .
#
# Usage:
#
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
   echo "    export PATH=\$PATH\`$me\`" # DO NOT echo anything after this.
   exit
fi

missing=""

if [ ! `which prizms-dependency-repos.sh &> /dev/null` ]; then
   missing=$missing":"$HOME/bin/install
fi

if [ ! `which pr-enable-dataset.sh &> /dev/null` ]; then
   missing=$missing":"$HOME/bin/dataset
fi

if [[ ! `which tdbloader &> /dev/null` ]]; then
   # When HOME is                  /home/lebot/opt/prizms
   # csv2rdf4lod installer creates /home/lebot/opt/apache-jena-2.7.4
   # and PATH needs to add         /home/lebot/opt/apache-jena-2.7.4/bin

   opt=`dirname $HOME`
   jenaroot=`find $opt -type d -name "apache-jena*"`

   if [[ -n "$missing" && -n "$jenaroot" && -e "$jenaroot" ]]; then
      missing=$missing":"$jenaroot/bin
   fi
fi


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

for situate in $HOME/repos/csv2rdf4lod-automation/bin/util/cr-situate-paths.sh \
               $HOME/repos/vsr/bin/vsr-situate-paths.sh                        \
               $HOME/repos/DataFAQs/bin/df-situate-paths.sh ; do
   missing=$missing`$situate`
done

# Replaced by for loop above:
#if [ -e $HOME/repos/csv2rdf4lod-automation/bin/util/cr-situate-paths.sh ]; then
#   missing=$missing`$HOME/repos/csv2rdf4lod-automation/bin/util/cr-situate-paths.sh`
#fi
#
#if [ -e $HOME/repos/DataFAQs/bin/df-situate-paths.sh ]; then
#   missing=$missing`$HOME/repos/DataFAQs/bin/df-situate-paths.sh`
#fi

echo $missing

#for path in `echo ${PATH//://  }`; do
#   echo $path
#done
