#!/bin/bash
#
#3> <> prov:specializationOf <https://github.com/timrdf/prizms/blob/master/bin/install.sh>;
#3>    rdfs:seeAlso <https://github.com/timrdf/prizms/wiki/Installing-Prizms> .

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
   echo
   echo "usage: `basename $0` [--me <your-URI>] [--my-email <your-email>] [--proj-user <user>] [--repos <code-repo>] "
   echo "                  [--upstream-ckan <ckan>] [--our-base-uri <uri>] [--our-source-id <source-id>]"
   echo
   echo "This script will determine and use the following parameters to install an instance of Prizms:"
   echo
   echo " --me            | [optional] the project developer's  URI                              (e.g. http://jsmith.me/foaf#me)"
   echo
   echo " --my-email      |            the project developer's  email address                    (e.g. me@jsmith.me)"
   echo "                 : the project developer's (i.e. your) user name (determined by whoami) (e.g. jsmith)"
   echo "                 : ^- this user will need sudo privileges."
   echo
   echo " --proj-user     | the project's                       user name                        (e.g. melagrid)"
   echo
   echo " --repos         | the project's code repository                                        (e.g. git@github.com:jimmccusker/melagrid.git)"
   echo
   echo " --upstream-ckan | [optional] the URL of a CKAN from which to pull dataset listings     (e.g. http://data.melagrid.org)"
   echo "                 : see https://github.com/jimmccusker/twc-healthdata/wiki/Retrieving-CKAN%27s-Dataset-Distribution-Files"
   echo
   echo " --our-base-uri  | the HTTP namespace for all datasets in the Prizms that we are making (e.g. http://lod.melagrid.org)"
   echo "                 : see https://github.com/timrdf/csv2rdf4lod-automation/wiki/Conversion-process-phase%3A-name"
   echo
   echo " --our-source-id | the identifier for *us* as an organization that produces datasets.   (e.g. melagrid-org)"
   echo "                 : see https://github.com/timrdf/csv2rdf4lod-automation/wiki/Conversion-process-phase%3A-name"
   echo
   echo "If the required parameters are not known, the script will ask for them interactively before installing anything."
   echo "The installer will ask permission before performing each install step, so that you know what it's doing."
   echo
   echo "https://github.com/timrdf/prizms/wiki"
   echo "https://github.com/timrdf/prizms/wiki/Installing-Prizms"
   echo
   exit
fi

# The parameters that we need to find out

#
person_uri=""
if [[ "$1" == "--me" ]]; then
   if [[ "$2" != --* ]]; then
      person_uri="$2"
      shift
   fi
   shift
fi

#
person_email=""
if [[ "$1" == "--my-email" ]]; then
   if [[ "$2" != --* ]]; then
      person_email="$2"
      shift
   fi
   shift
fi

#
person_user_name=`whoami`

#
project_user_name=""
if [[ "$1" == "--proj-user" ]]; then
   if [[ "$2" != --* ]]; then
      project_user_name="$2"
      shift
   fi
   shift
fi

#
project_code_repository=""
if [[ "$1" == "--repos" ]]; then
   if [[ "$2" != --* ]]; then
      project_code_repository="$2"
      shift
   fi
   shift
fi

#
upstream_ckan=""
if [[ "$1" == "--upstream-ckan" ]]; then
   if [[ "$2" != --* ]]; then
      upstream_ckan="$2"
      shift
   fi
   shift
fi

#
our_base_uri=""
if [[ "$1" == "--our-base-uri" ]]; then
   if [[ "$2" != --* ]]; then
      our_base_uri="$2"
      shift
   fi
   shift
fi

#
our_source_id=""
if [[ "$1" == "--our-source-id" ]]; then
   if [[ "$2" != --* ]]; then
      our_source_id="$2"
      shift
   fi
   shift
fi

div="-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
function change_source_me {
   echo
   echo $div
   target="$1"    #"data/source/csv2rdf4lod-source-me-for-$project_user_name.sh"
   ENVVAR="$2"    #'CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID'; 
   new_value="$3" #"$our_source_id"
   purpose="$4"   #"indicate the source identifier for all datasets that it creates on its own"
   see="$5"
   loss="$6"      #"in order for Prizms to create useful Linked Data URIs"
   echo "Prizms uses the shell environment variable $ENVVAR"
   echo "to $purpose."
   for ref in $see; do
      echo "  see $see"
   done
   if [[ -n "$new_value" ]]; then
      current=`$PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/value-of.sh $ENVVAR $target`
      if [ "$current" != "$new_value" ]; then
         echo
         echo "$ENVVAR is currently set to '$current' in $target"
         echo
         read -p "Q: May we change $ENVVAR to $new_value in $target? [y/n] " -u 1 change_it
         echo
         if [[ "$change_it" == [yY] ]]; then
            $PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/value-of.sh $ENVVAR $target --change-to $new_value
            echo "Okay, we changed $target to:"
            grep "export $ENVVAR=" $target | tail -1
            added="$added $target"
         else
            echo "Okay, we won't change it. You'll need to change it later$loss."
         fi
      else
         echo "($ENVVAR is already correctly set to $new_value in $target)"
      fi
   else
      echo "WARNING: We can't set the $ENVVAR in $target because it is not given."
   fi
}


echo
echo "Okay, let's install Prizms!"
echo "   https://github.com/timrdf/prizms/wiki"
echo "   https://github.com/timrdf/prizms/wiki/Installing-Prizms"

if [[ -z "$project_user_name" ]]; then
   echo
   echo "First, we need to know about the current user `whoami`."
   read -p "Q: Is `whoami` your project's user name? (y/n) " -u 1 it_is
   if [[ $it_is == [yY] ]]; then
      project_user_name=`whoami`
      echo "Your project's user name is: $project_user_name"
      echo
      echo $div
      read -p "Q: What is your user name? " -u 1 person_user_name
      echo "Okay, your user name is $person_user_name"
   else
      echo
      echo $div
      echo "Okay, `whoami` isn't your project's user name."
      read -p "Q: Is `whoami` _your_ user name? (y/n) "-u 1 it_is
      if [[ $it_is == [yY] ]]; then
         # https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD_PUBLISH_VARWWW_ROOT
         person_user_name=`whoami`
         echo "Okay, your user name is $person_user_name."
         echo
         echo $div
         echo "Prizms should be installed to a user name created specifically for the project."
         read -p "Q: Does your project have a user name yet? (y/n) "-u 1 it_does
         if [[ $it_does == [yY] ]]; then
            read -p "Q: What is the user name of your project? "-u 1 project_user_name
            if [ ! -e ~$project_user_name ]; then
               echo "ERROR: ~$project_user_name does not exist."
            else 
               echo "Okay, your project's user name is: $project_user_name"
            fi
         else
            echo "Okay, let's make a user name for your project."
            read -p "Q: What should your project's user name be? " -u 1 project_user_name
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
   read -p "Q: Where is $project_user_name's code repository (URL)?" -u 1 project_code_repository
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
   read -p "Q: Would you like your Prizms to pull dataset listings from a installation of CKAN?" -u 1 upstream_ckan
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
   read -p "Q: If you have one, what is your preferred URI for yourself (e.g. http://www.w3.org/People/Berners-Lee/card#i)? " person_uri
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


# https://github.com/timrdf/csv2rdf4lod-automation/wiki/Conversion-process-phase:-name
echo
echo $div
echo "Prizms generates its own versioned datasets based on other versioned datasets that it accumulates and integrates."
echo "These are called 'autonomic datasets' and provide added value on top of the collection of others' datasets."
echo "To organize these generated autonomic datasets properly, we need to know the right value for"
echo "the CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID environment variable. The identifier should indicate 'you', as either a"
echo "person or the organization that is setting up this instance of Prizms. The source-id is usually a cleaned up"
echo "string from your CSV2RDF4LOD_BASE_URI, e.g. http://lod.melagrid.org -> melagrid-org ('lod' does not indicate"
echo "the organization creating the datasets, so that part is dropped by convention)."
echo "See https://github.com/timrdf/csv2rdf4lod-automation/wiki/Conversion-process-phase:-name"
if [ -z "$our_source_id" ]; then
   echo
   read -p "Q: What source-id should we use for you (or your organization) as the creator of $project_user_name? " our_source_id
   echo
   if [ -n "$our_source_id" ]; then
      echo "Okay, we'll use $our_source_id for CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID"
   else
      echo "We won't be able to set up cr-cron.sh or any of the aggregated metadatasets for you,"
      echo "since those are organized under CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID."
      echo "See https://github.com/jimmccusker/twc-healthdata/wiki/Automation"
      echo "and https://github.com/timrdf/csv2rdf4lod-automation/wiki/Aggregating-subsets-of-converted-datasets"
      echo "and set CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID if you'd like to get the automation up and running in the future."
   fi
else
   echo "(We'll use the source-id that you already indicated: $our_source_id)"
fi


# https://github.com/timrdf/csv2rdf4lod-automation/wiki/Conversion-process-phase:-name
echo
echo $div
echo "Prizms names datasets and their entities within a base URI that is given in"
echo "the CSV2RDF4LOD_BASE_URI environment variable."
echo "See https://github.com/timrdf/csv2rdf4lod-automation/wiki/Conversion-process-phase:-name"
if [ -z "$our_base_uri" ]; then
   echo
   read -p "Q: What base URI should we use for your instance of Prizms ($project_user_name)? " our_base_uri
   echo
   if [ -n "$our_base_uri" ]; then
      echo "Okay, we'll use $our_base_uri for CSV2RDF4LOD_PUBLISH_BASE_URI"
   else
      echo "We won't be able to create Linked Data with useful URIs."
      echo "since we don't know what namespace to name them within (CSV2RDF4LOD_BASE_URI)."
      echo "See https://github.com/timrdf/csv2rdf4lod-automation/wiki/Conversion-process-phase:-name"
      echo "and set CSV2RDF4LOD_BASE_URI if you'd like useful Linked Data URIs in the future."
   fi
else
   echo "(We'll use the base URI that you already indicated: $our_base_uri)"
fi



echo
echo $div
echo $div
echo "                                    Ready to install"
echo $div
echo "We now have what we need to start installing Prizms:"
echo
if [ -n "$person_uri" ]; then
   echo "Your URI is:                                               $person_uri"
else
   echo "You don't have a URI."
fi
echo "Your user name is:                                         $person_user_name"
echo "Your project's user name is (or will be):                  $project_user_name"
echo "Your project's code repository ($vcs) is:                   $project_code_repository"
if [ -n "$upstream_ckan" ]; then
   echo "Your project will pull dataset listings from the CKAN at:  $upstream_ckan"  
else
   echo "Your project won't pull dataset listings from a CKAN (for now)."
fi
echo "Your project's Linked Data base URI is:                    $our_base_uri"
echo "Your project's source-id is:                               $our_source_id"

PRIZMS_HOME=$(cd ${0%/*} && echo ${PWD%/*})
me=$(cd ${0%/*} && echo ${PWD})/`basename $0`

echo
echo $div
echo "Okay, we'd like to install prizms at the following locations."
echo
echo "  $PRIZMS_HOME/"
echo "  $PRIZMS_HOME/repos"
echo
echo "    ^-- This is where we'll keep the Prizms utilities. Nothing in here will ever be specific to $project_user_name."
echo "        The repos/ directory will contain a variety of supporting utilities that Prizms uses from other projects."
echo
echo "  ~$person_user_name/prizms/$project_user_name"
echo
echo "    ^-- This is where you will develop $project_user_name, i.e. your application/instance of Prizms."
echo "        It will be your working copy of $project_code_repository"
echo
echo "  ~$project_user_name/prizms"
echo
echo "    ^-- This is where the production data and automation is performed and published."
echo "        The essential bits will be pulled read-only from $project_code_repository"
echo "        Automation will trigger on those essential bits to organize, describe, retrieve, convert, and publish your Linked Data."
echo "        To make changes in here, push into $project_code_repository from any working copy (e.g. ~$person_user_name/prizms/$project_user_name)"

if [[ `$PRIZMS_HOME/bin/install/project-user.sh $project_user_name --exists` == "no" ]]; then
   echo
   echo $div
   read -p "Create user $project_user_name? [y/n] " -u 1 install_project_user
   if [[ "$install_project_user" == [yY] ]]; then
      $PRIZMS_HOME/bin/install/project-user.sh $project_user_name
   else
      echo "ERROR: We need a user name."
      exit 1
   fi
fi


echo
echo $div
echo "Prizms combines a couple other projects, all of which are available on github."
echo "We'll retrieve those and place them in the directory $PRIZMS_HOME/repos/"
echo "If they're already there, we'll just update them from the latest on github."
$PRIZMS_HOME/bin/install/prizms-dependency-repos.sh


echo $div
clone='clone'
pull='pull'
if [ "$vcs" == "svn" ]; then
   clone="checkout"
   pull='update'
fi
pushd &> /dev/null
   cd
   echo "Now let's install your development copy of the $project_user_name Prizms."
   echo "(If you already have a working copy there, we'll update it.)"
   echo
   read -p "Q: May we run '$vcs $clone $project_code_repository' from `pwd`/prizms/? [y/n] " -u 1 install_it
   if [[ "$install_it" == [yY] ]]; then
      if [ ! -e prizms ]; then
         mkdir prizms
      fi
      pushd prizms &> /dev/null
         target_dir=`basename $project_code_repository`
         target_dir=${target_dir%.*}

         if [ ! -e $target_dir ]; then
            echo
            touch .before_clone
            $vcs $clone $project_code_repository
            status=$?
            dir=`find . -mindepth 1 -maxdepth 1 -type d -newer .before_clone`
            rm .before_clone
            echo

            if [ "$status" -eq 128 ]; then

               echo "It seems that you didn't have permissions to $clone $project_code_repository"
               echo "GitHub requires an ssh key to check out a writeable working clone"
               echo "See https://help.github.com/articles/generating-ssh-keys"
               echo

               if [ ! -e ~$person_user_name/.ssh/id_dsa.pub ]; then
                  read -p "Q: You don't have a ~$person_user_name/.ssh/id_dsa.pub; do you want to set one up now? [y/n] " timbo
                  if [[ "$timbo" == [yY] ]]; then
                     if [ -z "$user_email" ]; then
                        read -p "Q: We need your email address to set up an SSH key. What is it? " user_email
                     fi
                     if [ -n "$user_email" ]; then
                        #echo git config --global user.email $user_email
                        #     git config --global user.email $user_email

                        echo ssh-keygen -t dsa -C $user_email
                             ssh-keygen -t dsa -C $user_email
                     else
                        echo "WARNING `basename $0` needs an email address to set up an SSH key."
                     fi
                  else
                     echo "We didn't do anything to create an SSH key."
                  fi
                  if [ -e ~$person_user_name/.ssh/id_dsa.pub ]; then
                     echo "Great! You have a shiny new SSH key."
                     if [ "$vcs" == "git" ]; then
                        echo "Go add the following to https://github.com/settings/ssh"
                        cat ~$person_user_name/.ssh/id_dsa.pub
                        echo
                        read -p "Q: Finished adding your key? Once you do, we'll try running this install script again. Ready? [y]" finished
                        $0 --me $person_uri --my-email $user_email --proj-user $project_user_name --repos $project_code_repository \
                           --upstream-ckan $upstream_ckan --our-source-id $our_source_id
                        # ^ Recursive call
                     fi
                  fi
               else
                  echo "WARNING `basename $0`: ~$person_user_name/.ssh/id_dsa.pub exists, so we won't touch it."
                  echo "Please set up your ssh key for $project_code_repository and run this install script again."
                  echo "See https://help.github.com/articles/generating-ssh-keys"
               fi

            elif [ "$status" -ne 0 ]; then
               echo "We're not sure what happended; $vcs returned $status"
            else
               echo "Okay, $project_code_repository is now ${clone}'d to $dir." 
            fi
         fi
         if [ -e $target_dir ]; then
            pushd $target_dir &> /dev/null
               echo
               echo "$project_code_repository is already ${clone}'d into $target_dir; ${pull}'ing it..."
               $vcs $pull

               added=''

               if [[ ! -e data/source/ || ! -e lodspeakr/ || ! -e doc/ ]]; then
                  echo
                  echo $div
                  echo "Prizms reuses the directory conventions that csv2rdf4lod-automation uses."
                  echo "Following these conventions aids uniformity across many projects' offerings."
                  echo "For more, see https://github.com/timrdf/csv2rdf4lod-automation/wiki/Directory-Conventions"
                  echo
                  echo `pwd`/data/source/
                  echo `pwd`/lodspeakr/
                  echo `pwd`/doc/
                  echo
                  read -p "Q: ^-- May we create these directories in `pwd` if they don't already exist? [y/n] " -u 1 install_them
                  if [[ "$install_them" == [yY] ]]; then
                     if [ ! -e data/source ]; then
                        added="data"
                        echo "Creating `pwd`/data/source using stub from csv2rdf4lod-automation"
                        mkdir -p data
                        cp -R $PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/conversion-root-stub/* data/
                     fi
                     for directory in lodspeakr doc; do
                        if [ ! -e $directory ]; then
                           added="$added $directory"
                           echo "Creating `pwd`/$directory"
                           mkdir -p $directory
                        fi
                     done
                  fi
               fi
             



 
               # FOR PROJECT
               # 
               # Create the project-level environment variables, based on the template created by the csv2rdf4lod-automation installer.
               # See https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD-environment-variables
               #
               if [[ ! -e data/source/csv2rdf4lod-source-me-for-$project_user_name.sh && \
                       -e $PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/install.sh ]]; then
                  mv $PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/install.sh $PRIZMS_HOME/repos/csv2rdf4lod-automation/install.sh
               fi
               target="data/source/csv2rdf4lod-source-me-for-$project_user_name.sh"
               if [ -e $PRIZMS_HOME/repos/csv2rdf4lod-automation/install.sh ]; then
                  echo
                  echo $div
                  echo "Prizms uses the CSV2RDF4LOD_ environment variables that are part of csv2rdf4lod-automation."
                  echo "These environment variables are used to control how Prizms operates."
                  echo "See https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD-environment-variables"
                  echo
                  read -p "May we add the environment variables to `pwd`/$target? [y/n] " -u 1 add_them
                  if [[ "$add_them" == [yY] ]]; then
                     $PRIZMS_HOME/repos/csv2rdf4lod-automation/install.sh --non-interactive --vars-only | grep -v "^export CSV2RDF4LOD_HOME" > $target
                     added="$added $target"
                  else
                     echo "Okay, but at some point you should create these environment variables. Otherwise, we might not behave as you'd like us to."
                  fi
               fi

               #
               # Set CSV2RDF4LOD_BASE_URI in the project-level source-me.sh.
               #
               echo
               echo $div
               ENVVAR='CSV2RDF4LOD_BASE_URI'; new_value="$our_base_uri"
               echo "Prizms uses the shell environment variable $ENVVAR to"
               echo "indicate the Linked Data base URI to use for all datasets that it creates."
               target="data/source/csv2rdf4lod-source-me-for-$project_user_name.sh"
               if [[ -n "$new_value" && "$new_value" == http* ]]; then
                  current=`$PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/value-of.sh $ENVVAR $target`
                  if [ "$current" != "$new_value" ]; then
                     echo
                     echo "$ENVVAR is currently set to '$current' in $target"
                     read -p "Q: May we change $ENVVAR to $new_value in $target? [y/n] " -u 1 change_it
                     echo
                     if [[ "$change_it" == [yY] ]]; then
                        $PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/value-of.sh $ENVVAR $target --change-to $new_value
                        echo "Okay, we changed $target to:"
                        grep "export $ENVVAR=" $target | tail -1
                        added="$added $target"
                     else
                        echo "Okay, we won't change it. You'll need to change it in order for Prizms to create useful Linked Data URIs."
                     fi
                  else
                     echo "($ENVVAR is already correctly set to $new_value in $target)"
                  fi
               else
                  echo "WARNING: We can't set the $ENVVAR in $target because it is not given."
               fi

               #
               # Set CSV2RDF4LOD_CKAN_SOURCE (to $upstream_ckan) in the project-level source-me.sh.
               #
               if [[ "$upstream_ckan" == http* && -e "$target" ]]; then
                  echo
                  echo $div
                  echo "Prizms uses the shell environment variable CSV2RDF4LOD_CKAN_SOURCE to"
                  echo "indicate the upstream CKAN from which to pull dataset listings."

                  current=`$PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/value-of.sh 'CSV2RDF4LOD_CKAN_SOURCE' $target`
                  if [ "$current" != "$upstream_ckan" ]; then
                     echo
                     echo "CSV2RDF4LOD_CKAN_SOURCE is currently set to '$current' in $target"
                     read -p "Q: May we change CSV2RDF4LOD_CKAN_SOURCE to $upstream_ckan in $target? [y/n] " -u 1 change_it
                     echo
                     if [[ "$change_it" == [yY] ]]; then
                        $PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/value-of.sh 'CSV2RDF4LOD_CKAN_SOURCE' $target --change-to $upstream_ckan
                        echo "Okay, we changed $target to:"
                        grep 'export CSV2RDF4LOD_CKAN_SOURCE=' $target | tail -1
                        added="$added $target"
                     else
                        echo "Okay, we won't change it. You'll need to change it in order for Prizms to obtain $upstream_ckan's dataset listing."
                     fi
                  else
                     echo "(CSV2RDF4LOD_CKAN_SOURCE is already correctly set to $upstream_ckan in $target)"
                  fi # CSV2RDF4LOD_CKAN_SOURCE

                  current=`$PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/value-of.sh 'CSV2RDF4LOD_CKAN_SOURCE' $target`
                  if [ "$current" == "$upstream_ckan" ]; then
                     value=`$PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/value-of.sh 'CSV2RDF4LOD_CKAN' $target`
                     if [ "$value" != "true" ]; then
                        echo
                        echo "Although CSV2RDF4LOD_CKAN_SOURCE is set to $upstream_ckan, we still need to set CSV2RDF4LOD_CKAN to 'true'."
                        echo
                        read -p "Q: May we change CSV2RDF4LOD_CKAN to 'true' in $target? [y/n] " -u 1 change_it
                        echo
                        if [[ "$change_it" == [yY] ]]; then
                           $PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/value-of.sh 'CSV2RDF4LOD_CKAN' $target --change-to 'true'
                           echo "Okay, we changed $target to:"
                           grep 'export CSV2RDF4LOD_CKAN=' $target | tail -1
                           added="$added $target"
                        else
                           echo "Okay, we won't change CSV2RDF4LOD_CKAN_SOURCE. You'll need to set it to 'true' in order for Prizms to obtain $upstream_ckan's dataset listing."
                        fi
                     else
                        echo "(CSV2RDF4LOD_CKAN        is already correctly set to 'true' in $target)"
                     fi
                  fi # CSV2RDF4LOD_CKAN
               fi

               #
               # Set CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID (to $our_source_id) in the project-level source-me.sh.
               #
               echo
               echo $div
               target="data/source/csv2rdf4lod-source-me-for-$project_user_name.sh"
               ENVVAR='CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID'; new_value="$our_source_id"
               purpose="indicate the source identifier for all datasets that it creates on its own"
               loss="in order for Prizms to create useful Linked Data URIs"
               echo "Prizms uses the shell environment variable $ENVVAR to $purpose."
               if [[ -n "$new_value" ]]; then
                  current=`$PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/value-of.sh $ENVVAR $target`
                  if [ "$current" != "$new_value" ]; then
                     echo
                     echo "$ENVVAR is currently set to '$current' in $target"
                     read -p "Q: May we change $ENVVAR to $new_value in $target? [y/n] " -u 1 change_it
                     echo
                     if [[ "$change_it" == [yY] ]]; then
                        $PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/value-of.sh $ENVVAR $target --change-to $new_value
                        echo "Okay, we changed $target to:"
                        grep "export $ENVVAR=" $target | tail -1
                        added="$added $target"
                     else
                        echo "Okay, we won't change it. You'll need to change it later$loss."
                     fi
                  else
                     echo "($ENVVAR is already correctly set to $new_value in $target)"
                  fi
               else
                  echo "WARNING: We can't set the $ENVVAR in $target because it is not given."
               fi


               #TODO: CSV2RDF4LOD_PUBLISH_ANNOUNCE_TO_SINDICE="false" 

               # 1) source-me.sh 2) CSV_ 3) new-value 4) 'purpose' 4) 'loss'
               change_source_me $target CSV2RDF4LOD_PUBLISH_ANNOUNCE_TO_SINDICE true \
                  'determine if it should announce each newly converted dataset to http://sindice.com/main/submit' \
                  'https://github.com/timrdf/csv2rdf4lod-automation/wiki/Ping-the-Semantic-Web' \
                  'some loss'

               #TODO: CSV2RDF4LOD_PUBLISH_ANNOUNCE_TO_PTSW="false" 
               # TODO: CSV2RDF4LOD_PUBLISH_DATAHUB_METADATA


               # AS PROJECT
               #
               # csv2rdf4lod-source-me-as-${project_user_name}.sh is *the* one and only source-me.sh that 
               # the project name should source when initializing -- particular when from a cronjob.
               # This is *the* only source-me.sh that should appear in the project user name's ~/.bashrc
               #
               # This is created by the developer -- NOT the project user -- and committed to version control.
               template="$PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/conversion-root-stub/source/csv2rdf4lod-source-me-as-xxx.sh"
               target="data/source/csv2rdf4lod-source-me-as-$project_user_name.sh"
               if [[ ! -e $target ]]; then
                  cat $template | grep -v 'export CSV2RDF4LOD_CONVERT_PERSON_URI='                 > $target
                  echo "source `pwd`/data/source/csv2rdf4lod-source-me-for-$project_user_name.sh" >> $target
                  echo "source `pwd`/data/source/csv2rdf4lod-source-me-credentials.sh"            >> $target
                  # any others to source?

                  # TODO: set CSV2RDF4LOD_CONVERT_DATA_ROOT (ONLY for project user name, OR? ONLY for machine?)

                  added="$added $target"
                  echo
                  echo $div
                  echo "There wasn't a source-me.sh for your project's user name in the data conversion root, so we created one for you at $target"
               fi



               # AS DEVELOPER
               # 
               # Create a stub for the user-level environment variables, based on the template available from the csv2rdf4lod-automation.
               # See https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD-environment-variables-%28considerations-for-a-distributed-workflow%29
               # 
               template="$PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/conversion-root-stub/source/csv2rdf4lod-source-me-as-xxx.sh"
               target="data/source/csv2rdf4lod-source-me-as-$person_user_name.sh"
               if [[ ! -e $target ]]; then
                  cp $template $target
                  $PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/value-of.sh 'CSV2RDF4LOD_CONVERT_PERSON_URI' $target --change-to $person_uri
                  added="$added $target"
                  echo
                  echo $div
                  echo "There wasn't a source-me.sh for your user name in the data conversion root, so we created one for you at $target"
               fi

               #
               # Add PATH = PATH + sitaute paths to data/source/csv2rdf4lod-source-me-as-$person_user_name.sh
               #
               echo
               echo $div
               set_paths_cmd=`$PRIZMS_HOME/bin/install/paths.sh --help | tail -1 | sed 's/^ *//'`
               echo "The following command adds into your shell's environment the paths that Prizms requires to run its scripts."
               echo "Running it multiple times will have no effect, since only the missing paths are added."
               echo "For details, see https://github.com/timrdf/csv2rdf4lod-automation/wiki/situate-shell-paths-pattern"
               echo "The following command should appear in your data/source/csv2rdf4lod-source-me-as-$person_user_name.sh."
               echo
               echo "    $set_paths_cmd"
               target="data/source/csv2rdf4lod-source-me-as-$person_user_name.sh"
               already_there=`grep ".*export PATH=.*prizms/bin/install/paths.sh.*" $target`
               echo
               if [ -n "$already_there" ]; then
                  echo "It seems that you already have the following in your $target, so we won't offer to add it again:"
                  echo
                  echo $already_there
               else
                  echo "Add this command to your $target? [y/n]"
                  read -u 1 install_it
                  if [[ "$install_it" == [yY] ]]; then
                     echo $set_paths_cmd >> $target
                     echo
                     echo "Okay, we added it:"
                     grep ".*export PATH=.*prizms/bin/install/paths.sh.*" $target
                     added="$added $target"
                  else
                     echo "We didn't touch your $target, so you'll need to make sure you set the paths correctly each time."
                  fi
               fi

               #
               # Add CLASSPATH = CLASSPATH + sitaute paths to data/source/csv2rdf4lod-source-me-as-$person_user_name.sh
               #
               echo
               echo $div
               set_paths_cmd=`$PRIZMS_HOME/bin/install/classpaths.sh --help | tail -1 | sed 's/^ *//'`
               echo "The following command adds into your shell's environment the Java class paths that Prizms requires to run its scripts."
               echo "Just like the previous paths.sh command, running this multiple times will have no effect, since only the missing paths are added."
               echo "For details, see https://github.com/timrdf/csv2rdf4lod-automation/wiki/situate-shell-paths-pattern"
               echo "The following command should appear in your data/source/csv2rdf4lod-source-me-as-$person_user_name.sh."
               echo
               echo "    $set_paths_cmd"
               target="data/source/csv2rdf4lod-source-me-as-$person_user_name.sh"
               already_there=`grep ".*export CLASSPATH=.*prizms/bin/install/classpaths.sh.*" $target`
               echo
               if [ -n "$already_there" ]; then
                  echo "It seems that you already have the following in your $target, so we won't offer to add it again:"
                  echo
                  echo $already_there
               else
                  echo "Add this command to your $target? [y/n]"
                  read -u 1 install_it
                  if [[ "$install_it" == [yY] ]]; then
                     echo $set_paths_cmd >> $target
                     echo
                     echo "Okay, we added it:"
                     grep ".*export CLASSPATH=.*prizms/bin/install/classpaths.sh.*" $target
                     added="$added $target"
                  else
                     echo "We didn't touch your $target, so you'll need to make sure you set the paths correctly each time."
                  fi
               fi

               # End setting the environment variables for project, project user, and developer user.






               # Start installing dependencies.

               #
               # We need to check the /etc/hosts before we try to install Virtuoso as a dependency,
               # otherwise dpkg will fail to build it when called by csv2rdf4lod-automation's install-dependencies.sh.
               #
               echo
               echo $div
               echo "Virtuoso will have issues if it is on a virtual machine and /etc/hosts's localhost is 127.0.0.1 instead of the VM's IP."
               # Hack for our pseudo-VMs. This needs to be done before installing virtuoso with install-csv2rdf4lod-dependencies.sh
               #
               # vi /etc/hosts
               # 127.0.0.1    localhost
               # 192.168.1.45    melagrid melagrid.aquarius.tw.rpi.edu
               # ->
               # 192.168.1.45    localhost
               # 192.168.1.45    melagrid melagrid.aquarius.tw.rpi.edu

               # This issue is partially discussed at:
               # https://github.com/timrdf/csv2rdf4lod-automation/wiki/Publishing-conversion-results-with-a-Virtuoso-triplestore

               # The following ERROR is fixed by the /etc/hosts change shown above:
               #
               # Selecting previously deselected package virtuoso-opensource.
               # (Reading database ... 34197 files and directories currently installed.)
               # Unpacking virtuoso-opensource (from .../virtuoso-opensource_6.1.6_amd64.deb) ...
               # Setting up virtuoso-opensource (6.1.6) ...
               # Starting OpenLink Virtuoso Open-Source Edition: The VDBMS server process terminated prematurely
               # after initializing network connections.
               # invoke-rc.d: initscript virtuoso-opensource, action "start" failed.
               # dpkg: error processing virtuoso-opensource (--install):
               #  subprocess installed post-installation script returned error exit status 104
               # Processing triggers for ureadahead ...
               # Errors were encountered while processing:
               #  virtuoso-opensource
               # 
               # cannot:
               target=/etc/hosts
               localhost_ip=`cat $target | awk '$2=="localhost"{print $1}'`
               vm_ip=`grep "tw.rpi.edu" $target | awk '{print $1}'`
               if [[ -n "$vm_ip" && "$localhost_ip" == "127.0.0.1" ]]; then
                  echo "$target is currently:"
                  echo
                  cat $target
                  echo
                  echo "We'd like to change the IP of 'localhost' to $vm_ip, resulting in a $target of:"
                  echo
                  cat $target | awk -v ip=$vm_ip '{if($2=="localhost"){print ip,"localhost"}else{print}}' > .`basename $0`.hosts
                  cat .`basename $0`.hosts
                  echo
                  echo "Changing the IP of localhost to the VM's IP should let Virtuoso start up correctly."
                  read -p "Q: May we make the change to $target?" -u 1 change_it
                  if [[ "$change_it" == [yY] ]]; then
                     echo sudo mv $target $target.prizms.bck
                          sudo mv $target $target.prizms.bck
                     echo sudo mv .`basename $0`.hosts $target
                          sudo mv .`basename $0`.hosts $target
                     echo
                     echo "We changed $target; it is now:"
                     cat $target
                  else
                     rm .`basename $0`.hosts
                     echo "Okay, we won't change $target. But if you try to install Virtuoso and this is a virtual machine, you'll run into issues."
                     echo "See:"
                     echo "  https://github.com/jimmccusker/twc-healthdata/wiki/VM-Installation-Notes#wiki-virtuoso"
                  fi
               else
                  echo "(locahost's IP is $localhost_ip; Virtuoso should not have any issues.)"
               fi 

               #
               # Install third party utilities (mostly with apt-get and tarball installs).
               #
               echo
               echo $div
               echo "Prizms uses a variety of third party utilities that we can try to install for you automatically."
               echo "The following utilities seem to already be installed okay:"
               echo
               $PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/install-csv2rdf4lod-dependencies.sh -n | grep "^.okay"
              
               TODO=`$PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/install-csv2rdf4lod-dependencies.sh -n | grep "^.TODO" | grep -v "pydistutils.cfg"`
               if [ -n "$TODO" ]; then
                  echo "todo${TODO}todo"
                  echo
                  echo "However, the following do not seem to be installed:"
                  echo
                  $PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/install-csv2rdf4lod-dependencies.sh -n | grep "^.TODO" | grep -v "pydistutils.cfg"
                  echo
                  read -p "Q: May we try to install the dependencies listed above? (We'll need root for most of them) [y/n] " -u 1 install_them
                  echo
                  if [[ "$install_them" == [yY] ]]; then
                     touch .before-prizms-installed-dependencies
                     $PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/install-csv2rdf4lod-dependencies.sh
                  else
                     echo "Okay, we won't try to install them. Check out the following if you want to do it yourself:"
                     echo "  https://github.com/timrdf/csv2rdf4lod-automation/wiki/Installing-csv2rdf4lod-automation---complete"
                     #echo "This installer will quit now, instead of trying to finish."
                     #exit 1
                  fi
               fi




               virtuoso_installed="no"
               if [[ -e '/var/lib/virtuoso/db/virtuoso.ini' && \
                     -e '/usr/bin/isql-v'                   && \
                     -e '/etc/init.d/virtuoso-opensource'   && \
                     -e '/var/lib/virtuoso/db/virtuoso.log' ]]; then
                  virtuoso_installed="yes"
               fi
               if [[ "$virtuoso_installed" == "yes" ]]; then

                  # 1111 is Virtuoso's default port to access its "JDBC".
                  # 8890 is Virtuoso's default port for its web app admin interface.
                  # 
                  # If Virtuoso is installed on a VM, access it's Conductor webapp from your own laptop using something like:
                  #
                  # ssh -L 8890:localhost:8890 -p 2245 -l smithj aquarius.tw.rpi.edu
                  #
                  #        |    |         |       |       |      ^ The machine that hosts the VM.
                  #        |    |         |       |       ^ Your user name.
                  #        |    |         |       ^ The port on aquarius that my VM is on.
                  #        |    |         ^ The port on the VM that Virtuoso serves its SPARQL endpoint.
                  #        |    ^ Your machine, e.g. your laptop.
                  #        ^ The port on your machine that you connect to in order to get to the VM's Virtuoso SPARQL endpoint.
                  # 
                  # Now, load up http://localhost:8890/conductor in your laptop's web browser, and you're viewing the service from the VM.

                  echo
                  echo $div
                  target="/var/lib/virtuoso/db/virtuoso.ini"
                  data_root=`cd; echo ${PWD%/*}`/$project_user_name/prizms/data/
                  already_set=`grep 'DirsAllowed' $target | grep -v $data_root`
                  echo "Virtuoso can only access the directories that are specified in $target's 'DirsAllowed' setting."
                  echo "If you have an RDF file in some *other* directory, you will not be able to load it into Virtuoso,"
                  echo "or -- if it does -- it can take more storage and time than is actually needed to load."

                  if [[ -n "$already_set" ]]; then
                     echo "'DirsAllowed' is currently set as:"
                     echo
                     grep DirsAllowed $target
                     # ^ e.g. DirsAllowed         = ., /usr/share/virtuoso/vad

                     echo
                     echo "Prizms needs Virtuoso to have permission to access the files in $data_root"
                     echo "in order to load RDF files efficiently."
                     echo "This is done by adding $data_root to Virtuoso's 'DirsAllowed'"
                     echo
                     cat $target | awk -v data_root=$data_root '{if($1 == "DirsAllowed"){print $0", "data_root}else{print}}' | grep "DirsAllowed"
                     echo
                     read -p "Q: May we add $data_root to the 'DirsAllowed' setting in $target (as shown above)? [y/n] " -u 1 install_it
                     echo
                     if [[ "$install_it" == [yY] ]]; then
                        cat $target | awk -v data_root=$data_root '{if($1 == "DirsAllowed"){print $0", "data_root}else{print}}' > .`basename $0`.ini
                        echo sudo mv $target $target.prizms.backup
                             sudo mv $target $target.prizms.backup
                        echo sudo mv .`basename $0`.ini $target
                             sudo mv .`basename $0`.ini $target
                        echo
                        echo "Okay, we added to 'DirsAllowed'. Not it is set as:"
                        echo
                        grep DirsAllowed $target
                        echo
                        echo "Virtuoso needs to be restarted for the setting to take effect, which can be done with:"
                        echo
                        echo "   sudo /etc/init.d/virtuoso-opensource stop"
                        echo "   sudo /etc/init.d/virtuoso-opensource start"
                        echo
                        read -p "Restart virtuoso now (with the command above)? [y/n] " -u 1 restart_it
                        if [[ "$restart_it" == [yY] ]]; then
                           sudo /etc/init.d/virtuoso-opensource stop
                           sudo /etc/init.d/virtuoso-opensource start
                        else
                           echo "Okay, we won't restart virtuoso. But you'll need to restart it to load data from $target."
                           echo "See:"
                           echo "  https://github.com/jimmccusker/twc-healthdata/wiki/VM-Installation-Notes#wiki-virtuoso"
                           echo "  https://github.com/timrdf/csv2rdf4lod-automation/wiki/Publishing-conversion-results-with-a-Virtuoso-triplestore"
                        fi
                     else
                        echo "Okay, we won't modify $target. See the following:"
                        echo "  https://github.com/jimmccusker/twc-healthdata/wiki/VM-Installation-Notes#wiki-virtuoso"
                        echo "  https://github.com/timrdf/csv2rdf4lod-automation/wiki/Publishing-conversion-results-with-a-Virtuoso-triplestore"
                     fi
                  else
                     echo "($target already has $data_root included in its 'DirsAllowed' setting.)"
                  fi

                  echo
                  echo $div
                  credentials="/etc/prizms/$person_user_name/triple-store/virtuoso/csv2rdf4lod-source-me-for-virtuoso-credentials.sh"
                  if [[ -e $credentials ]]; then
                     vpw=`$PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/value-of.sh 'CSV2RDF4LOD_PUBLISH_VIRTUOSO_PASSWORD' $credentials`
                  fi
                  if [[ -z "$vpw" ]]; then
                     echo "If you just installed Virtuoso, and haven't changed the default password for the user 'dba',"
                     echo "you should do that now at http://localhost:8890/conductor."
                     if [[ -n "$vm_ip" ]]; then
                        echo "If you installed Virtuoso on a VM, you can access it through an SSN tunnel with something like:"
                        echo
                        echo "   ssh -L 8890:localhost:8890 -p 2245 -l smithj aquarius.tw.rpi.edu"
                        echo
                        echo "Once the tunnel it set up, you can load http://localhost:8890/conductor to access the VM's conductor."
                     fi
                     echo
                     echo "1) Log in using the panel on the left."
                     echo "2) Click 'System Admin' tab on the top."
                     echo "3) Click 'User Accounts' tab on the top."
                     echo "4) Click 'Edit' to the right of user 'dba'."
                     echo "5) Set and confirm the new password, and hit 'Save' at the bottom."
                     echo
                     read -p "Q: Did you change the default password for Virtuoso user 'dba'? [y/n] " -u 1 changed
                     if [[ "$changed" != [yY] ]]; then
                        echo "Okay, we can proceed with a default password, but you should be worried about security issues in the future."
                     fi
                     echo
                     echo "Prizms stores Virtuoso credentials outside of version control, so that they are kept from the public." 
                     if [[ ! -e $credentials ]]; then
                        echo
                        read -p "Q: May we set up $credentials to maintain the Virtuoso credentials? [y/n] " -u 1 do_it
                        if [[ "$do_it" == [yY] ]]; then
                           echo sudo mkdir -p `dirname $credentials`
                                sudo mkdir -p `dirname $credentials`
                           if [[ -e `dirname $credentials` ]]; then
                              echo
                              echo "Prizms uses CSV2RDF4LOD_PUBLISH_VIRTUOSO_USERNAME and CSV2RDF4LOD_PUBLISH_VIRTUOSO_PASSWORD to"
                              echo "authenticate to the Virtuoso database with the isql-v command."
                              echo
                              read -p "Q: What is the Virtuoso database username (for isql-v)? (leave empty to default to 'dba') " vuser
                              read -p "Q: What is the Virtuoso database password (for isql-v)? (leave empty to default to 'dba') " vpw 
                              echo
                              if [[ -n "$vuser" ]]; then
                                 echo "export CSV2RDF4LOD_PUBLISH_VIRTUOSO_USERNAME='$vuser'" | sudo tee $credentials
                              fi
                              if [[ -n "$vpw" ]]; then
                                 echo "export CSV2RDF4LOD_PUBLISH_VIRTUOSO_PASSWORD='$vpw'"   | sudo tee -a $credentials
                              fi
                              #echo "CSV2RDF4LOD_PUBLISH_VIRTUOSO_PORT"
                           else
                              echo "ERROR: could not create `dirname $credentials`"
                           fi
                        else
                           echo "Okay, we won't create $credentials. But we won't be able to use Virtuoso to load RDF data."
                           echo "See https://github.com/timrdf/csv2rdf4lod-automation/wiki/Publishing-conversion-results-with-a-Virtuoso-triplestore"
                        fi
                     fi
                  fi
                  if [[ -e $credentials ]]; then
                     target="data/source/csv2rdf4lod-source-me-credentials.sh"
                     echo "$target is a public version controlled script that points to all credentials required for the project."
                     already_there=`grep $credentials $target`
                     if [[ -z $already_there ]]; then
                        echo
                        read -p "Add 'source $credentials' to $target? [y/n] " -u 1 add_it
                        echo "source $credentials" >> $target
                        echo "Added."
                        added="$added $target"
                     else
                        echo "($target already includes $credentials)"
                     fi
                  fi

                  #target="data/source/csv2rdf4lod-source-me-as-$person_user_name.sh"

                  echo
                  echo $div
                  echo TODO add the apache map /sparql to 8890
                  # add to /etc/apache2/sites-available/std.common
                  # See mapping into apache at https://github.com/jimmccusker/twc-healthdata/wiki/VM-Installation-Notes#wiki-virtuoso
                  #
                  #  <Location /sparql>
                  #      allow from all
                  #      SetHandler None
                  #      Options +Indexes
                  #      ProxyPass               http://localhost:8890/sparql
                  #      ProxyPassReverse        /sparql
                  #    # ProxyHTMLExtended On
                  #    # ProxyHTMLURLMap url\(/([^\)]*)\) url(/sparql$1) Rihe
                  #    # ProxyHTMLURLMap         /sparql /sparql
                  #    # ProxyHTMLURLMap         http://localhost:8890/sparql /sparql
                  #  </Location>
                  #
                  # a2enmod ??
                  # service apache2 restart
                  #
                  # We're trying to get to http://aquarius.tw.rpi.edu/projects/melagrid/sparql

                  # TODO: set CSV2RDF4LOD_PUBLISH_SPARQL_ENDPOINT (and the VIRTUOSO one?)

               fi # end $virtuoso_install






               #
               # Add source data/source/csv2rdf4lod-source-me-as-$person_user_name.sh to ~/.bashrc
               #
               echo
               echo $div
               source_me="source `pwd`/data/source/csv2rdf4lod-source-me-as-$person_user_name.sh"
               echo "Prizms encapsulates all of the environment variables and PATH setup that is needed within"
               echo "a single source-me.sh script dedicated to the user that needs it. The script is version-controlled"
               echo "so we can manage the environment variables that everybody uses. The single source-me.sh should be the *only*"
               echo "source-me.sh that is called from your ~/.bashrc. The following command is the only"
               echo "source-me.sh that you need to run, and should be placed within your ~/.bashrc."
               echo
               echo "   $source_me"
               already_there=`grep ".*source \`pwd\`/data/source/csv2rdf4lod-source-me-as-$person_user_name.sh.*" ~/.bashrc`
               echo
               if [ -n "$already_there" ]; then
                  echo "It seems that you already have the following in your ~/.bashrc, so we won't offer to add it again:"
                  echo
                  echo $already_there
               else
                  see="https://github.com/timrdf/csv2rdf4lod-automation/wiki/Script:-source-me.sh"
                  echo "Add this command to your ~/.bashrc? [y/n]"
                  read -u 1 install_it
                  if [[ "$install_it" == [yY] ]]; then
                     echo                     >> ~/.bashrc
                     echo "$source_me # $see ">> ~/.bashrc
                     echo
                     echo "Okay, we added it:"
                     grep "$source_me" ~/.bashrc
                  else
                     echo "We didn't change your ~/.bashrc, so you'll need to make sure you set the paths correctly each time."
                     echo "See $see"
                  fi
               fi




               # TODO: Create csv2rdf4lod-source-me-on-melagrid.sh (machine)
               # TODO WARNING: set JENAROOT=/home/lebot/opt/apache-jena-2.7.4 in your my-csv2rdf4lod-source-me.sh or .bashrc
               # TODO WARNING: set PATH="${PATH}:/home/lebot/opt/apache-jena-2.7.4/bin" in your my-csv2rdf4lod-source-me.sh or .bashrc
               # TODO: JENAROOT add to source-me-as-lebot/melagrid

               # TODO: implement "cr-review-vars.sh"
               # TODO: CSV2RDF4LOD_PUBLISH_DATAHUB_METADATA and CSV2RDF4LOD_PUBLISH_DATAHUB_METADATA_OUR_BUBBLE_ID
               # TODO: CSV2RDF4LOD_PUBLISH_ANNOUNCE_TO_SINDICE
               # TODO: X_GOOGLE_MAPS_API_Key
               # TODO: set up the user-based install that does NOT require sudo. python's easy_install
               # TODO: CSV2RDF4LOD_PUBLISH_VARWWW_ROOT

         
   





               #
               # TODO Sprinkle "access.ttl" files within the csv2rdf4lod conversion root, as mirrors of the upstream CKAN.
               #
               # http://data.melagrid.org/cowabunga/dude.html -> data-melagrid-org
               echo
               echo $div
               export CLASSPATH=$CLASSPATH`$PRIZMS_HOME/bin/install/classpaths.sh` 
               upstream_ckan_source_id=`java edu.rpi.tw.string.NameFactory --source-id-of $upstream_ckan`
               target="data/source/$upstream_ckan_source_id"
               echo "Prizms can collect and convert datasets that are listed in CKAN instances."
               echo "You've specified an upstream CKAN from which to mirror dataset listings ($upstream_ckan),"
               echo "but Prizms hasn't extracted the access metadata into $target."
               echo
               if [[ -n "$upstream_ckan_source_id" && ! -e $target ]]; then
                  read -p "Extract the access metadata from the datasets in $upstream_ckan, placing them within $target? [y/n] " -u 1 extract_it
                  if [[ "$extract_it" == [yY] ]]; then
                     mkdir -p $target
                     pushd $target &> /dev/null
                        echo cr-create-dataset-dirs-from-ckan.py $upstream_ckan $our_base_uri
                     popd &> /dev/null
                  else
                     echo "Okay, we won't try to extract access metadata from $upstream_ckan. Check out the following if you want to do it yourself:"
                     echo "  https://github.com/jimmccusker/twc-healthdata/wiki/Mirroring-a-Source-CKAN-Instance"
                  fi
               fi



               #
               # Set up cr-cron.sh
               #
               echo
               echo $div
               template="$PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/cr-cron.sh"
               target="data/source/$our_source_id/cr-cron/version/cr-cron.sh"
               echo "TODO: talk about the automation"
               echo
               if [[ -n "$our_source_id" ]]; then
                  if [[ ! -e $target ]]; then
                     read -p "There isn't a $target in your repository, should we add it for you? [y/n] " -u 1 install_it
                     echo
                     if [[ "$install_it" == [yY] ]]; then
                        mkdir -p `dirname $target`
                        cp $template $target
                        added="$added $target"
                        echo "Okay, we added $target"
                     else
                        echo "Okay, we didn't add $target, but your Prizms won't automatically update."
                        echo "See https://github.com/jimmccusker/twc-healthdata/wiki/Automation"
                        echo "and https://github.com/timrdf/csv2rdf4lod-automation/wiki/Aggregating-subsets-of-converted-datasets"
                     fi
                  else
                     echo "(`pwd`/$target is already set up,"
                     echo " and is ready for the $project_user_name project user to add to its crontab.)"
                  fi
               else
                  echo "(WARNING We can't set up $target because we don't know what source-id we should use.)"
               fi
               # NOTE: setting up the cron should be done on the project user name side, NOT on the person user name side.







               #
               # Add all new files to version control.
               #
               if [ -n "$added" ]; then
                  echo
                  echo $div
                  echo "We just added the following to `pwd`"
                  echo "   $added"
                  echo
                  read -p "Q: ^--- Since we modified these files to your working copy of $project_code_repository, let's add, commit, and push them, okay? [y/n] " -u 1 push_them
                  if [[ "$push_them" == [yY] ]]; then
                     git add $added
                     git commit -m 'During install: added stub directories and readme files.'
                     git push
                  else
                     echo
                     echo "Okay, we won't push anything to $project_code_repository; but at some point, you should run:"
                     echo
                     echo git add $added
                     echo git commit -m 'During install: added stub directories and readme files.'
                     echo git push
                  fi
               fi

            popd &> /dev/null
         fi # if $target_dir e.g. /home/lebot/prizms/melagrid
      popd &> /dev/null
   else
      echo "If you aren't going to use a code repository, we can't help you very much."
   fi
popd &> /dev/null



exit


# TODO: work the following into this installer:


# https://github.com/alangrafu/lodspeakr/wiki/How-to-install-requisites-in-Ubuntu
echo "Dependency for LODSPeaKr:"
offer_install_with_apt 'a2enmod' 'apache2'

# curl already done by csv2rdf4lod-automation's install-csv2rdf4lod-dependencies.sh

for package in php5 php5-cli php5-sqlite php5-curl sqlite3; do
   not_installed=`dpkg -s $package 2>&1 | grep "is not installed"`
   if [[ -n "$not_installed" && "$dryrun" != "true" ]]; then
      echo
      echo "~~~~ ~~~~"
   fi  
   if [[ -n "$not_installed" ]]; then
      echo $TODO sudo apt-get install $package
      if [[ "$dryrun" != "true" ]]; then
         read -p "$package (Dependency for LODSPeaKr) is not shown in dpkg; install it with command above? (y/N) " -u 1 install_it
         if [[ "$install_it" == [yY] ]]; then
            sudo apt-get install $package
         fi  
      fi  
   else
      echo "[okay] $package is installed (needed for LODSPeaKr)."
   fi  
done

echo
echo "~~~~ ~~~~"
echo "sudo a2enmod rewrite"
read -p "LODSPeaKr requires HTTP rewrite. Enable it with the command above? (y/N) " -u 1 install_it
if [[ "$install_it" == [yY] ]]; then
   sudo a2enmod rewrite
fi

echo
echo "~~~~ ~~~~"
echo 'https://github.com/alangrafu/lodspeakr/wiki/How-to-install-requisites-in-Ubuntu:'
echo "  /etc/apache2/sites-enabled/000-default must 'AllowOverride All' for <Directory /var/www/>"
echo
echo "sudo service apache2 restart"
read -p "Please edit 000-default to AllowOverride All, THEN type 'y' to restart apache, or just type 'N' to skip this. (y/N) " -u 1 install_it
if [[ "$install_it" == [yY] ]]; then
   echo "~~~~ ~~~~"
   echo "Dependency for LODSPeaKr:"
   sudo service apache2 restart
fi


