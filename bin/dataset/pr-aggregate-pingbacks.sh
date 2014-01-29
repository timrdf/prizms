#!/bin/bash
#
#3> <> a conversion:RetrievalTrigger, conversion:Idempotent;
#3>    prov:specializationOf <https://github.com/timrdf/prizms/blob/master/bin/dataset/pr-aggregate-pingbacks.sh>;
#3>    prov:wasDerivedFrom   <https://github.com/timrdf/csv2rdf4lod-automation/blob/master/bin/dataset/cr-aggregate-dcat.sh>;
#3>    rdfs:seeAlso          <https://github.com/timrdf/csv2rdf4lod-automation/wiki/Aggregating-subsets-of-converted-datasets> .

[ -n "`readlink $0`" ] && this=`readlink $0` || this=$0
HOME=$(cd ${this%/*/*} && echo ${PWD%/*})
export PATH=$PATH`$HOME/bin/install/paths.sh`
export CLASSPATH=$CLASSPATH`$HOME/bin/install/classpaths.sh`

# cr:data-root cr:source cr:directory-of-datasets cr:dataset cr:directory-of-versions cr:conversion-cockpit
ACCEPTABLE_PWDs="cr:bone"
if [ `is-pwd-a.sh $ACCEPTABLE_PWDs` != "yes" ]; then
   pwd-not-a.sh $ACCEPTABLE_PWDs
   exit 1
fi

if [[ "$1" == "--help" ]]; then
   section='#aggregation-39-dataset-conversion-metadata-prov-o-dcterms-void'
   echo "usage: `basename $0` [-n] [version-identifier]"
   echo ""
   echo "Create a dataset from the aggregation of all csv2rdf4lod conversion parameter files."
   echo ""
   echo "               -n : perform dry run only; do not load named graph."
   echo "see https://github.com/timrdf/csv2rdf4lod-automation/wiki/Aggregating-subsets-of-converted-datasets$section"
   echo
   exit
fi

dryrun="false"
if [ "$1" == "-n" ]; then
   dryrun="true"
   III="dryrun_"
   dryrun.sh $dryrun beginning
   shift
fi

# "SDV" naming
if [[ -n "$CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID" ]]; then
   sourceID="$CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID"
elif [[ `is-pwd-a.sh 'cr:data-root'` == "yes" ]]; then
   section='#csv2rdf4lod_publish_our_source_id'
   see="https://github.com/timrdf/csv2rdf4lod-automation/wiki/Secondary-Derivative-Datasets$section"
   sourceID=${CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID:?"not set and ambiguous based on level in data root; see $see"}
else
   sourceID=`cr-source-id.sh`
fi
datasetID=`basename $this | sed -e 's/.sh$//'`
if [[ "$1" != "" ]]; then
   versionID="$1"
elif [[ `is-pwd-a.sh 'cr:conversion-cockpit'` == "yes" ]]; then
   versionID=`cr-version-id.sh`
else
   versionID=`date +%Y-%b-%d`
fi

pushd `cr-conversion-root.sh` &> /dev/null
   cockpit="$sourceID/$datasetID/version/$versionID"
   if [ "$dryrun" != "true" ]; then
      mkdir -p $cockpit/source $cockpit/automatic &> /dev/null
      rm -rf $cockpit/source/* $cockpit/automatic/${III}includes.txt $cockpit/automatic/includes.txt &> /dev/null
   fi

   # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   echo "Aggregating all Pingback access metadata in `pwd` into $cockpit/source/." >&2
   # from e.g.
   # ./healthdata-tw-rpi-edu/prov-pingback/version/20140123-1390489968-016e-98c11745f80caf7eb39dd0012a6b256c/access.ttl
   # ./provenanceweb-org/prov-pingback/version/20140123-1390489968-016e-f716f5b6fa6e2aa10164b4cd2ea51a7a/access.ttl
   for access in `find . -mindepth 5 -maxdepth 5 -name access.ttl`; do
      echo
      echo "  ${access#./}"
      pingpit=`dirname $access`
      if [[ `rdf2nt.sh $access | grep '<http://purl.org/twc/vocab/conversion/PingbackDataset>' | wc -l | awk '{print $1}'` -gt 0 ]]; then
         sdv=$(cd $pingpit && cr-sdv.sh)
         if [[ -e $pingpit/source && ! -e $pingpit/publish ]]; then
            # Retrieved but not published.
            acceptable=''
            for prov in `find $pingpit/source -name "*.prov.ttl"`; do
               pingback=${prov%.prov.ttl}
               if [[ -e "$pingback" ]]; then
                  echo "    source/`basename $prov`"
                  echo "        about pingback source/`basename $pingback`"
                  if [[ -e "$pingback" && `valid-rdf.sh $pingback` != 'yes' ]]; then
                     echo "    WARNING: `basename $0` removing pingback b/c not valid RDF: source/`basename $pingback`"
                     if [ "$dryrun" != "true" ]; then
                        rm $pingback $prov
                        echo `basename $pingback` >> $pingpit/source/cleansed.txt
                     fi
                  else
                     if [[ `rdf2nt.sh $pingback | grep '<http://www.w3.org/ns/prov#' | wc -l | awk '{print $1}'` -gt 0 ]]; then
                        acceptable="$acceptable source/`basename $pingback`" 
                        echo "        $cockpit/source/$sdv.ttl"
                        #if [ "$dryrun" != "true" ]; then
                        #   ln $pingback $cockpit/source/$sdv.ttl
                        #fi
                     else
                        echo "        Valid RDF, but does not contain PROV-O statements (not publishing): `basename $pingback`."
                     fi
                  fi
               fi
            done
            if [[ -n "$acceptable" ]]; then
               echo
               echo "  -- publishing$acceptable"
               if [ "$dryrun" != "true" ]; then
                  pushd $pingpit &> /dev/null
                     aggregate-source-rdf.sh "$acceptable"
                  popd &> /dev/null
               fi
            else
               echo "    (retrieved, but nothing acceptable)"
            fi
         elif [[ ! -e $pingpit/source ]]; then
            echo "    (not yet retrieved)"
         elif [[ -e $pingpit/source && -e $pingpit/publish ]]; then
            echo "    (already retrieved and published)"
         else
            echo "    (??)"
         fi

         for prov in `find $pingpit/source -name "*.prov.ttl"`; do
            pingback=${prov%.prov.ttl}
            if [[ -e "$pingback" ]]; then
               has_been_aggregated='no'
               is_in_version=''
               for includes in `find $sourceID/$datasetID -mindepth 4 -maxdepth 4 -name "includes.txt"`; do
                  if [[ "$has_been_aggregated" != 'yes' ]]; then
                     path=`grep $pingback $includes`
                     there=$?
                     if [[ "$there" == 0 ]]; then
                        has_been_aggregated='yes'
                        is_in_version="$includes"
                     fi
                  fi   
               done
               if [[ "$has_been_aggregated" != 'yes' ]]; then
                  echo "    (will include in this version)"
                  if [ "$dryrun" != "true" ]; then
                     pushd ${pingback%source/*} &> /dev/null
                        sdv=`cr-sdv.sh`
                     popd &> /dev/null
                     ln -s `pwd`/$pingback `pwd`/$cockpit/source/$sdv
                  fi
                  echo "$pingback" >> $cockpit/automatic/${III}includes.txt
               else
                  echo "    (already included in pr-aggregate-pingbacks version $is_in_version"
               fi
            fi
         done

      else
         echo "    (not a PingbackDataset)"
      fi
   done
   # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   pushd $cockpit &> /dev/null
      echo
      echo aggregate-source-rdf.sh --link-as-latest automatic/meta.ttl source/*.ttl
      if [ "$dryrun" != "true" ]; then
         cr-default-prefixes.sh --turtle                                     > automatic/meta.ttl
         echo "<`cr-dataset-uri.sh --uri`> a conversion:AggregateDataset ." >> automatic/meta.ttl
         cat automatic/meta.ttl | grep -v "@prefix"
   
         aggregate-source-rdf.sh --link-as-latest automatic/meta.ttl source/*.ttl
     fi
  popd &> /dev/null

popd &> /dev/null
dryrun.sh $dryrun ending
