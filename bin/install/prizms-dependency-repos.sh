#!/bin/bash
#
# <> prov:specializationOf <https://github.com/timrdf/prizms/blob/master/bin/install/prizms-dependency-repos.sh>;
#    prov:wasDerivedFrom   <https://github.com/timrdf/prizms/blob/master/bin/install/project-user.sh> .
#

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
   echo
   echo "usage: `basename $0` [-n]"
   echo
   echo "  Retrieves the dependency code repositories (e.g. csv2rdf4lod-automation, lodspeakr, DataFAQs, vsr)."
   exit
fi

PRIZMS_HOME=$(cd ${0%/*/*} && echo ${PWD%/*})
me=$(cd ${0%/*} && echo ${PWD})/`basename $0`

if [ ! -e $PRIZMS_HOME/repos ]; then
   mkdir -p $PRIZMS_HOME/repos
fi

if [ ! -e $PRIZMS_HOME/lodspeakrs ]; then
   mkdir -p $PRIZMS_HOME/lodspeakrs
fi

pushd $PRIZMS_HOME/repos &> /dev/null
   for repos in https://github.com/timrdf/csv2rdf4lod-automation.git \
                https://github.com/timrdf/DataFAQs.git \
                https://github.com/timrdf/vsr.git; do
      echo
      directory=`basename $repos`
      directory=${directory%.*}
      echo $directory...
      if [ ! -e $directory ]; then
         echo git clone $repos
              git clone $repos
      else
         pushd $directory &> /dev/null
            git pull
         popd &> /dev/null
      fi
   done
   if [[ ! -e semanteco-annotator-webapp.zip ]]; then
      # See https://github.com/timrdf/prizms/wiki/csv2rdf4lod-annotator
      echo "curl semanteco-annotator-webapp.zip"
      curl --insecure 'https://orion.tw.rpi.edu/jenkins/job/semanteco-prizms-support/lastStableBuild/edu.rpi.tw.escience%24semanteco-annotator-webapp/artifact/*zip*/archive.zip'> semanteco-annotator-webapp.zip
   fi
   echo
popd &> /dev/null

#
# https://github.com/timrdf/prizms/issues/12
#
pushd $PRIZMS_HOME/lodspeakrs &> /dev/null
   for repos in https://github.com/jimmccusker/twc-healthdata.git; do
      echo
      directory=`basename $repos`
      directory=${directory%.*}
      echo $directory...
      if [ ! -e $directory ]; then
         echo git clone $repos
              git clone $repos
         #echo git init $directory # sparse causes 'origin' conflict with the prizms repository.
         #     git init $directory
         #pushd $directory &> /dev/null
         #   echo git remote add -f origin $repos
         #        git remote add -f origin $repos
         #   git config core.sparsecheckout true
         #   echo lodspeakr >> .git/info/sparse-checkout
         #   git pull origin master
         #popd
      else
         pushd $directory &> /dev/null
            git pull
            #git pull origin master
         popd &> /dev/null
      fi
   done
   echo
popd &> /dev/null
