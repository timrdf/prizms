#!/bin/bash
#
# <> prov:specializationOf <> .
#

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
   echo
   echo "usage: `basename $0` [--me <your-URI>] [--proj-user <user>] [--repos <code-repo>] [--upstream-ckan <ckan>]"
   echo
   echo "This script will determine and use the following parameters to install an instance of Prizms:"
   echo
   echo " --me            : [optional] the project administrator's URI                           (e.g. http://jsmith.me/foaf#me)"
   echo "                 : the project developer's (i.e. your) user name (determined by whoami) (e.g. jsmith)"
   echo "                   ^- this user will need sudo privileges."
   echo " --proj-user     : the project's                       user name                        (e.g. melagrid)"
   echo " --repos         : the project's code repository                                        (e.g. git@github.com:jimmccusker/melagrid.git)"
   echo " --upstream-ckan : [optional] the URL of a CKAN from which to pull dataset listings     (e.g. http://data.melagrid.org)"
   echo
   echo "If the required parameters are not known, the script will ask for them before installing anything."
   echo
   echo "https://github.com/timrdf/prizms/wiki"
   echo "https://github.com/timrdf/prizms/wiki/Installing-Prizms"
   echo
   exit
fi

# The parameters that we need to find out

#
person_uri=""
if [[ "$1" == "--me" && $# -gt 1 ]]; then
   person_uri="$2"
   shift 2
fi

#
person_user_name=`whoami`

#
project_user_name=""
if [[ "$1" == "--proj-user" && $# -gt 1 ]]; then
   project_user_name="$2"
   shift 2
fi

#
project_code_repository=""
if [[ "$1" == "--repos" && $# -gt 1 ]]; then
   project_code_repository="$2"
   shift 2
fi

#
upstream_ckan=""
if [[ "$1" == "--upstream-ckan" && $# -gt 1 ]]; then
   upstream_ckan="$2"
   shift 2
fi




echo "Okay, let's install Prizms!"
echo "   https://github.com/timrdf/prizms/wiki"
echo "   https://github.com/timrdf/prizms/wiki/Installing-Prizms"

div="-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
if [[ -z "$project_user_name" ]]; then
   echo
   echo "First, we need to know about the current user `whoami`."
   echo -n "Q: Is `whoami` your project's user name? (y/n) "
   read -u 1 it_is
   if [[ $it_is == [yY] ]]; then
      project_user_name=`whoami`
      echo "Your project's user name is: $project_user_name"
      echo
      echo $div
      echo -n "Q: What is your user name? "
      read -u 1 person_user_name
      echo "Okay, your user name is $person_user_name"
   else
      echo
      echo $div
      echo "Okay, `whoami` isn't your project's user name."
      echo -n "Q: Is `whoami` _your_ user name? (y/n) "
      read -u 1 it_is
      if [[ $it_is == [yY] ]]; then
         # https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD_PUBLISH_VARWWW_ROOT
         person_user_name=`whoami`
         echo "Okay, your user name is $person_user_name."
         echo
         echo $div
         echo "Prizms should be installed to a user name created specifically for the project."
         echo -n "Q: Does your project have a user name yet? (y/n) "
         read -u 1 it_does
         if [[ $it_does == [yY] ]]; then
            echo -n "Q: What is the user name of your project? "
            read -u 1 project_user_name
            if [ ! -e ~$project_user_name ]; then
               echo "ERROR: ~$project_user_name does not exist."
            else 
               echo "Okay, your project's user name is: $project_user_name"
            fi
         else
            echo "Okay, let's make a user name for your project."
            echo -n "Q: What should your project's user name be? "
            read -u 1 project_user_name
            echo "Okay, your project's user name will be: $project_user_name"
         fi
      else
         echo "ERROR: Then whose user name is it?"
         echo "Run `basename $0` again as either the project user name or as your user name."
         exit 1
      fi
   fi
   if [ -z "$project_user_name" ]; then
      echo "ERROR: we can't install Prizms because we need a user name for it."
      exit 1
   fi
fi

echo
echo $div
echo "It is important to maintain your Prizms using version control."
echo "It helps you maintain your site, it facilitates collaboration with others, and it encourages reproducibility by others."
if [ -z "$project_code_repository" ]; then
   echo -n "Q: Where is $project_user_name's code repository (URL)?"
   read -u 1 project_code_repository
else
   echo "(We'll use the code repository that you already indicated: $project_code_repository)"
fi
vcs=""
if [ -n "$project_code_repository" ]; then
   if [[ "$project_code_repository" == git* ]]; then
      vcs="git"
   elif [[ "$project_code_repository" == svn* ]]; then
      vcs="svn"
   else
      echo "ERROR: Could not determine version control system from the repository URL $project_code_repository"
      exit 1
   fi   
else
   echo "ERROR: Sorry, we need a code repository to work with."
   exit 1
fi


echo
echo $div
echo "Prizms can pull dataset listings from an installation of CKAN,"
echo "which can make it easier to gather the datasets that you'd like to integrate."
echo "It's fine not to pull from a CKAN, so if you don't want to, just leave this blank."
if [ -z "$upstream_ckan" ]; then
   echo -n "Q: Would you like your Prizms to pull dataset listings from a installation of CKAN?"
   read -u 1 upstream_ckan
   if [ -n "$upstream_ckan" ]; then
      echo "Okay, we'll pull dataset listings from the CKAN $upstream_ckan"
   else
      echo "Okay, we won't bother with CKAN listings."
   fi
else
   echo "(We'll use the upstream CKAN that you already indicated: $upstream_ckan)"
fi

# https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD_CONVERT_PERSON_URI
echo
echo $div
echo "Prizms can include you in the provenance that it captures."
echo "This can give you credit for the work that you're doing to create great data."
if [ -z "$person_uri" ]; then
   see='https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD_CONVERT_PERSON_URI'
   echo "If you provide a URI for yourself, we can get you credit for the data that you produce."
   echo "See $see."
   echo -n "If you have one, what is your preferred URI for yourself (e.g. http://www.w3.org/People/Berners-Lee/card#i)? "
   read -u 1 person_uri
   if [ -n "$person_uri" ]; then
      echo "Okay, your URI is $person_uri"
   else
      echo "Okay, you don't have a URI. We can press forward without it, but you won't get credit in some of our provenance."
      echo "See $see"
      echo "and set CSV2RDF4LOD_CONVERT_PERSON_URI to your URI if you'd like to get some credit in the future."
   fi
else
   echo "(We'll use the URI that you already indicated: $person_uri)"
fi

echo
echo $div
echo $div
echo "                                    Ready to install"
echo $div
echo "We now have what we need to start installing Prizms:"
echo
if [ -n "$person_uri" ]; then
   echo "Your URI is:                              $person_uri"
else
   echo "You don't have a URI."
fi
echo "Your user name is:                        $person_user_name"
echo "Your project's user name is (or will be): $project_user_name"
echo "Your project's code repository ($vcs):     $project_code_repository"
if [ -n "$upstream_ckan" ]; then
   echo "You will pull dataset listings from CKAN: $upstream_ckan"  
else
   echo "You won't pull dataset listings from a CKAN."
fi

echo
echo $div
echo "Okay, we'd like to install prizms at the following locations."
echo
echo "  ~$person_user_name/prizms/$project_user_name <-- This is where you will develop $project_user_name."
echo "  ~$project_user_name/prizms <-- This is where the production data and automation is performed and published."

PRIZMS_HOME=$(cd ${0%/*} && echo ${PWD%/*})
me=$(cd ${0%/*} && echo ${PWD})/`basename $0`

if [[ `$PRIZMS_HOME/bin/install/project-user.sh $project_user_name --exists` == "no" ]]; then
   echo
   echo -n "Create user $project_user_name? [y/n] "
   read -u 1 install_project_user
   if [[ "$install_project_user" == [yY] ]]; then
      $PRIZMS_HOME/bin/install/project-user.sh $project_user_name
   else
      echo "ERROR: We need a user name."
      exit 1
   fi
fi
