#!/bin/bash
#
#
#
# WARNING: DO NOT EDIT THIS FILE 
#
#   ... if it appears as a retrieval trigger in a Prizms instance's data root.
#   Editing this file will also edit the system default in the Prizms installation, e.g. ~/opt/prizms/bin/,
#     which may lead to conflicts when updating Prizms' installation.
#
#
#
#3> <> prov:specializationOf <https://github.com/timrdf/prizms/tree/master/bin/dataset/pr-neighborlod.sh>;
#3>    prov:wasDerivedFrom   <https://github.com/timrdf/prizms/tree/master/bin/dataset/pr-spobal-ng.sh>;
#3>    rdfs:seeAlso          <https://github.com/timrdf/prizms/wiki/pr-spobal-ng>,
#3>                          <https://github.com/timrdf/csv2rdf4lod-automation/wiki/Secondary-Derivative-Datasets>;
#3> .
#
# This script sets up a new version of a dataset when given a URL to a tabular file and some options
# describing its structure (comment character, header line, and delimter).
#
# If you have a non-tabular file, or custom software to retrieve data, then this script can be 
# used as a template for the retrieve.sh that is placed in the version directory.
#
# See:
# https://github.com/timrdf/csv2rdf4lod-automation/wiki/Automated-creation-of-a-new-Versioned-Dataset
#

[ `readlink $0` != "" ] && this=`readlink $0` || this=$0
#                                ^                    ^ e.g. ./retrieve.sh
#                                | e.g. /home/lebot/opt/prizms/bin/dataset/pr-neighborlod.sh
HOME=$(cd ${this%/*} && echo $PWD/${this##*/})
echo ${this%/*}
echo $this
echo $HOME

exit
see="https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD-not-set"
CSV2RDF4LOD_HOME=${CSV2RDF4LOD_HOME:?"not set; source csv2rdf4lod/source-me.sh or see $see"}

# cr:data-root cr:source cr:directory-of-datasets cr:dataset cr:directory-of-versions cr:conversion-cockpit
ACCEPTABLE_PWDs="cr:directory-of-versions cr:conversion-cockpit"
if [ `${CSV2RDF4LOD_HOME}/bin/util/is-pwd-a.sh $ACCEPTABLE_PWDs` != "yes" ]; then
   ${CSV2RDF4LOD_HOME}/bin/util/pwd-not-a.sh $ACCEPTABLE_PWDs
   exit 1
fi

if [[ `cr-pwd-type.sh` == "cr:conversion-cockpit" ]]; then
   pushd ../ &> /dev/null
fi

TEMP="_"`basename $0``date +%s`_$$.tmp

if [[ "$1" == "--help" ]]; then
   echo "usage: `basename $0` [version-identifier] [URL]"
   echo "   version-identifier: conversion:version_identifier for the VersionedDataset to create. Can be '', 'cr:auto', 'cr:today', 'cr:force'."
   echo "   URL               : URL to use during retrieval."
   exit 1
fi


#-#-#-#-#-#-#-#-#
version="$1"
version_reason=""
url="$2"
if [[ "$1" == "cr:auto" && ${#url} -gt 0 ]]; then
   version=`urldate.sh $url`
   #echo "Attempting to use URL modification date to name version: $version"
   version_reason="(URL's modification date)"
fi
if [[ ${#version} -eq 0                        || \
      ${#version} -ne 11 && "$1" == "cr:auto"  || \
                            "$1" == "cr:today" || \
                            "$1" == "cr:force" ]]; then
   # We couldn't determine the date from the URL (11 length from e.g. "2013-Aug-12")
   # Or, there was no URL given.
   # Or, we're told to use today's date.
   version=`cr-make-today-version.sh 2>&1 | head -1`
   #echo "Using today's date to name version: $version"
   version_reason="(Today's date)"
fi
if [[ -e "$version" && "$1" == "cr:force"  ]]; then
   version=`date +%Y-%b-%d-%H-%M_%s`
fi
if [ ${#version} -gt 0 -a `echo $version | grep ":" | wc -l | awk '{print $1}'` -gt 0 ]; then
   # No colons allowed?
   echo "Version identifier invalid."
   exit 1
fi
shift 2

echo "INFO url       : $url" # TODO: run spo balance for this name, if it's given.
echo "INFO version   : $version $version_reason"

#
# This script is invoked from a cr:directory-of-versions, 
# e.g. source/contactingthecongress/directory-for-the-112th-congress/version
#
if [[ ! -d $version || ! -d $version/source || `find $version -empty -type d -name source` ]]; then

   see='https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD-environment-variables'
   endpoint=${CSV2RDF4LOD_PUBLISH_VIRTUOSO_SPARQL_ENDPOINT:?"not set; source csv2rdf4lod/source-me.sh or see $see"}

   # Create the directory for the new version.
   mkdir -p $version/source

   # Go into the directory that stores the original data obtained from the source organization.
   echo INFO `cr-pwd.sh`/$version/source
   pushd $version/source &> /dev/null
      touch .__CSV2RDF4LOD_retrieval # Make a timestamp so we know what files were created during retrieval.
      # - - - - - - - - - - - - - - - - - - - - Replace below for custom retrieval  - - - \
      if [[ "$endpoint" =~ http* && \
            -e ../../../src/unsummarized.rq && 
            `which cache-queries.sh` ]]; then
         cache-queries.sh "$endpoint" -o csv -q ../../../src/unsummarized.rq -od .
      else
         echo "   ERROR: Failed to create dataset `basename $0`:"                        
         echo "      CSV2RDF4LOD_PUBLISH_VIRTUOSO_SPARQL_ENDPOINT: $endpoint"        
         echo "      cache-queries.sh path: `which cache-queries.sh`"
         echo "      ../../../src/unsummarized.rq:"
         ls -lt ../../../src/unsummarized.rq
      fi
      if [ "$CSV2RDF4LOD_RETRIEVE_DROID_SOURCES" != "false" ]; then                     # |
         sleep 1                                                                        # |
         cr-droid.sh . > cr-droid.ttl                                                   # |
      fi                                                                                # |
      # - - - - - - - - - - - - - - - - - - - - Replace above for custom retrieval - - - -/
   popd &> /dev/null

   # Go into the conversion cockpit of the new version.
   worthwhile="no"
   pushd $version &> /dev/null

      if [ ! -e automatic ]; then
         mkdir automatic
      fi

      retrieved_files=`find source -newer source/.__CSV2RDF4LOD_retrieval -type f | grep -v "pml.ttl$" | grep -v "cr-droid.ttl$"`

      ng=''
      for sd_name in `cat source/unsummarized.rq.csv | sed 's/^"//;s/"$//' | grep "^http"`; do
         worthwhile="yes"
         ng_ugly=`resource-name.sh --named-graph $endpoint $sd_name`
         ng_hash=`md5.sh -qs "$ng_ugly"`
         ng="$endpoint/id/named-graph/$ng_hash" 
         echo
         echo "<$ng> sd:name <$sd_name> ."
         echo
         vsr-spo-balance.sh -s "$endpoint" . "$sd_name" > automatic/$ng_hash.ttl
      done

      if [[ "$ng" != '' ]]; then
         aggregate-source-rdf.sh automatic/*.ttl
      fi

   popd &> /dev/null

   if [[ "$worthwhile" != 'yes' ]]; then
      echo
      echo "Note: version $version of dataset `cr-dataset-id.sh` did not become worthwhile; removing retrieval attempt."
      echo
      rm -rf $version
   fi
else
   echo "Version exists; skipping."
fi

if [[ `cr-pwd-type.sh` == "cr:conversion-cockpit" ]]; then
   popd ../ &> /dev/null
fi
