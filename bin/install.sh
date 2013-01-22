#!/bin/bash
#
# <> prov:specializationOf <https://github.com/timrdf/prizms/blob/master/bin/install.sh> .
#

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
   echo
   echo "usage: `basename $0` [--me <your-URI>] [--my-email <your-email>] [--proj-user <user>] [--repos <code-repo>] [--upstream-ckan <ckan>]"
   echo
   echo "This script will determine and use the following parameters to install an instance of Prizms:"
   echo
   echo " --me            : [optional] the project developer's URI                               (e.g. http://jsmith.me/foaf#me)"
   echo " --my-email      :            the project developer's email address                     (e.g. me@jsmith.me)"
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




echo
echo "Okay, let's install Prizms!"
echo "   https://github.com/timrdf/prizms/wiki"
echo "   https://github.com/timrdf/prizms/wiki/Installing-Prizms"

div="-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
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
   read -p "If you have one, what is your preferred URI for yourself (e.g. http://www.w3.org/People/Berners-Lee/card#i)? " person_uri
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
   echo "Your URI is:                                       $person_uri"
else
   echo "You don't have a URI."
fi
echo "Your user name is:                                 $person_user_name"
echo "Your project's user name is (or will be):          $project_user_name"
echo "Your project's code repository ($vcs):              $project_code_repository"
if [ -n "$upstream_ckan" ]; then
   echo "Your project will pull dataset listings from CKAN: $upstream_ckan"  
else
   echo "Your project won't pull dataset listings from a CKAN (for now)."
fi

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
echo "        the repos/ directory will contain a variety of supporting utilities that Prizms uses from other projects."
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
set_paths_cmd=`$PRIZMS_HOME/bin/install/paths.sh --help | tail -1 | sed 's/^ *//'`
echo "The following command will add the paths that Prizms requires."
echo "Running it multiple times will have no effect, since only the missing paths are added."
echo "For details, see https://github.com/timrdf/csv2rdf4lod-automation/wiki/situate-shell-paths-pattern"
echo
echo "    $set_paths_cmd"
already_there=`grep ".*export PATH=.*prizms/bin/install/paths.sh.*" ~/.bashrc`
echo
if [ -n "$already_there" ]; then
   echo "It seems that you already have the following in your ~/.bashrc, so we won't offer to add it again:"
   echo
   echo $already_there
else
   echo "Add this command to your ~/.bashrc? [y/n]"
   read -u 1 install_it
   if [[ "$install_it" == [yY] ]]; then
      echo $set_paths_cmd >> ~/.bashrc
   else
      echo "We didn't touch your ~/.bashrc, so you'll need to make sure you set the paths correctly each time."
   fi
fi

echo
echo $div
clone='clone'
pull='pull'
if [ "$vcs" == "svn" ]; then
   clone="checkout"
   pull='update'
fi
pushd &> /dev/null
   cd
   echo "Now let's install your development copy of your Prizms."
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
                        $0 --me $person_uri --my-email $user_email --proj-user $project_user_name --repos $project_code_repository --upstream-ckan $upstream_ckan
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
               
               if [[ ! -e data/source/csv2rdf4lod-source-me-for-$project_user_name.sh && \
                       -e $PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/install.sh ]]; then
                  mv $PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/install.sh $PRIZMS_HOME/repos/csv2rdf4lod-automation/install.sh
               fi
               if [ -e $PRIZMS_HOME/repos/csv2rdf4lod-automation/install.sh ]; then
                  echo
                  echo $div
                  echo "Prizms uses the CSV2RDF4LOD_ environment variables that are part of csv2rdf4lod-automation."
                  echo "These environment variables are used to control how Prizms operates."
                  echo "See https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD-environment-variables"
                  echo
                  read -p "May we add the environment variables to `pwd`/data/source/csv2rdf4lod-source-me-for-$project_user_name.sh? [y/n] " -u 1 add_them
                  if [[ "$add_them" == [yY] ]]; then
                     $PRIZMS_HOME/repos/csv2rdf4lod-automation/install.sh --non-interactive --vars-only > data/source/csv2rdf4lod-source-me-for-$project_user_name.sh
                     added="$added data/source/csv2rdf4lod-source-me-for-$project_user_name.sh"
                  else
                     echo "Okay, but at some point you should create these environment variables. Otherwise, we might not behave as you'd like us to."
                  fi
               fi

               template="$PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/conversion-root-stub/source/csv2rdf4lod-source-me-as-xxx.sh"
               target="data/source/csv2rdf4lod-source-me-as-$person_user_name.sh"
               if [[ ! -e $target ]]; then
                  cp $template $target
                  perl -pi -e "s/export CSV2RDF4LOD_CONVERT_PERSON_URI=.*/export CSV2RDF4LOD_CONVERT_PERSON_URI='$person_uri'/" $target
                  added="$added $target"
               fi

               if [ -n "$added" ]; then
                  echo
                  echo $div
                  echo "We just added the following to `pwd`"
                  echo "   $added"
                  echo
                  read -p "Since we added some files to your working copy of $project_code_repository, let's add, commit, and push them, okay? [y/n] " -u 1 push_them
                  if [[ "$push_them" == [yY] ]]; then
                     git add $added
                     git commit -m 'During install: added stub directories and readme files.'
                     git push
                  else
                     echo "Okay, we won't push anything to $project_code_repository; but at some point, you should run:"
                     echo
                     echo git add $added
                     echo git commit -m 'During install: added stub directories and readme files.'
                     echo git push
                  fi
               fi

               # TODO: move .bashrc edit to source-me
               # TODO: implement "cr-review-vars.sh"
               # TODO: set env var for upstream-ckan
               # TODO: install csv2rdf4lod-dependencies.
               # TODO: mirror ckan and commit dcats.ttls

            popd &> /dev/null
         fi # if $target_dir e.g. /home/lebot/prizms/melagrid
      popd &> /dev/null
   else
      echo "If you aren't going to use a code repository, we can't help you very much."
   fi
popd &> /dev/null






