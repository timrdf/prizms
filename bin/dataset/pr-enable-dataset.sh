#!/bin/bash
#
#3> <> prov:specializationOf <https://github.com/timrdf/prizms/blob/master/bin/dataset/pr-enable-dataset.sh> .
#
# Usage:
#
#   export PATH=$PATH`$DATAFAQS_HOME/bin/df-situate-paths.sh`
#   (can be repeated indefinitely, once paths are in PATH, nothing is returned.)

HOME=$(cd ${0%/*/*} && echo ${PWD%/*})
me=$(cd ${0%/*} && echo ${PWD})/`basename $0`

see='https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD-not-set'
CSV2RDF4LOD_HOME=${CSV2RDF4LOD_HOME:?"not set; source csv2rdf4lod/source-me.sh or see $see"}

# cr:data-root cr:source cr:directory-of-datasets cr:dataset cr:directory-of-versions cr:conversion-cockpit
ACCEPTABLE_PWDs="cr:data-root cr:source"
if [ `${CSV2RDF4LOD_HOME}/bin/util/is-pwd-a.sh $ACCEPTABLE_PWDs` != "yes" ]; then
   ${CSV2RDF4LOD_HOME}/bin/util/pwd-not-a.sh $ACCEPTABLE_PWDs
   exit 1
fi

TEMP="_"`basename $0``date +%s`_$$.tmp

if [[   `cr-pwd-type.sh` == 'cr:data-root' ]]; then
   DATA=$(cd ../ && echo ${PWD})
   trim="source/"
elif [[ `cr-pwd-type.sh` == 'cr:source' ]]; then
   DATA=$(cd ../../ && echo ${PWD})
   trim="source/$CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID/"
fi

if [[ -z "$CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID" && \
      `${CSV2RDF4LOD_HOME}/bin/util/is-pwd-a.sh cr:source` == "yes" ]]; then
   export CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID=`cr-source-id.sh`
fi

see="https://github.com/timrdf/csv2rdf4lod-automation/wiki/Aggregating-subsets-of-converted-datasets"
CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID=${CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID:?"not set; see $see"}

retrieves=`dirname $me`

if [[ $# -eq 0 ]]; then
   echo "Available datasets:"
   me_local=`basename $me`
   available=`find $retrieves -type f -name "pr-*" -not -name $me_local`
   if [[ -d $HOME/repos/csv2rdf4lod-automation/bin ]]; then
      available="$available `grep -RIl '#3> <> a conversion:RetrievalTrigger;' $HOME/repos/csv2rdf4lod-automation/bin`"
   fi
   for retrieve in $available; do
      datasetID=`basename $retrieve | sed 's/.sh$//'`
      retrieval_trigger=$DATA/source/$CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID/$datasetID/version/retrieve.sh
      if [[ -e $retrieval_trigger ]]; then
         enabled='enabled'
      else
         enabled='*not* enabled'
      fi
      echo "   $datasetID   is $enabled at ${retrieval_trigger#$DATA/$trim} ($retrieve)"
   done
else
   datasetID="$1"
   retrieval_trigger=$DATA/source/$CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID/$datasetID/version/retrieve.sh
   src=$DATA/source/$CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID/$datasetID/src

   if [[ ! -e $retrieves/$datasetID.sh ]]; then
      echo "ERROR: dataset $datasetID is not available: $retrieves/$datasetID.sh"
   elif [[ -e $retrieval_trigger ]]; then
      echo "Warning: Did not create ${retrieval_trigger#$DATA/$trim} because it already exists: $retrieval_trigger."
   else
      mkdir -p `dirname $retrieval_trigger`
      ln -s $retrieves/$datasetID.sh $retrieval_trigger
      echo "Created ${retrieval_trigger#$DATA/$trim} -> $retrieves/$datasetID.sh"
   fi

   if [[ -e $retrieves/$datasetID && ! -e $src ]]; then
      ln -s $retrieves/$datasetID $src
      echo "Created ${src#$DATA/$trim} -> $retrieves/$datasetID"
   fi
fi
