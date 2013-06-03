#!/bin/bash
#
#3> <> prov:specializationOf <https://github.com/timrdf/prizms/blob/master/bin/install.sh>;
#3>    rdfs:seeAlso <https://github.com/timrdf/prizms/wiki/Installing-Prizms> .

if [[ ${0%install.sh} == $0 ]]; then # $0 is 'bash' etc when bootstrapping, it is the path of the script otherwise.

   if [[ "$0" == "bash" ]]; then
      # Invoked with bootstrap install command:
      # bash < <(curl -sL http://purl.org/twc/install/prizms | grep -v "^#..bin/bash$")
      cd
      read -p "Q: Bootstrap Prizms installation at `pwd`/opt/prizms? [y/n] " -u 1 install_it
      if [[ "$install_it" == [yY] ]]; then
         if [[ ! `which git` ]]; then
            echo
            echo "We need git to bootstrap Prizms' installation."
            echo "git can be installed on Ubuntu with the command:"
            echo
            echo "  sudo apt-get install git-core"
            echo
            read -p "Q: Try to install git with the command above? [y/n] " -u 1 install_it
            echo
            if [[ "$install_it" == [yY] ]]; then
               sudo apt-get install git-core < <(echo 'y')
            fi
         fi
         if [[ `which git` ]]; then
            echo
            echo mkdir -p `pwd`/opt
            echo
            mkdir -p `pwd`/opt
            cd opt
            echo git clone git://github.com/timrdf/prizms.git
            git clone git://github.com/timrdf/prizms.git
            echo
            echo "Prizms bootstrap is installed. Run:"
            echo "  opt/prizms/bin/install.sh --help"
         fi
      else
         echo "Okay, we won't do anything." 
      fi
   fi

else

   PRIZMS_HOME=$(cd ${0%/*} && echo ${PWD%/*})
   user_home=$(cd && echo ${PWD})
   me=$(cd ${0%/*} && echo ${PWD})/`basename $0`

   if [[ "$1" == "--help" || "$1" == "-h" ]]; then
      echo
      echo "usage: `basename $0` [--me <your-URI>] [--my-email <your-email>] [--proj-user <user>] [--repos <code-repo>] "
      echo "                  [--upstream-ckan <ckan>] [--our-base-uri <uri>] [--our-source-id <source-id>]"
      echo "                  [--our-datahub-id]"
      echo
      echo "This script will determine and use the following parameters to install an instance of Prizms:"
      echo "  (these arguments must be provided in the order listed)"
      echo
      echo " --me             | [optional] the project developer's  URI                              (e.g. http://jsmith.me/foaf#me)"
      echo
      echo " --my-email       |            the project developer's  email address                    (e.g. me@jsmith.me)"
      echo "                  : This email will be used to create an SSH key (if none exists; with your confirmation)"
      echo "                  : This email will be set as git's user.email setting (with your confirmation)"
      echo
      echo " --proj-user      | the project's                       user name                        (e.g. melagrid)"
      echo
      echo " --repos          | the project's code repository                                        (e.g. git@github.com:jimmccusker/melagrid.git)"
      echo
      echo " --upstream-ckan  | [optional] the URL of a CKAN from which to pull dataset listings     (e.g. http://data.melagrid.org)"
      echo "                  : see https://github.com/jimmccusker/twc-healthdata/wiki/Retrieving-CKAN%27s-Dataset-Distribution-Files"
      echo
      echo " --our-base-uri   | the HTTP namespace for all datasets in the Prizms that we are making (e.g. http://lod.melagrid.org)"
      echo "                  : see https://github.com/timrdf/csv2rdf4lod-automation/wiki/Conversion-process-phase%3A-name"
      echo
      echo " --our-source-id  | the identifier for *us* as an organization that produces datasets.   (e.g. melagrid-org)"
      echo "                  : see https://github.com/timrdf/csv2rdf4lod-automation/wiki/Conversion-process-phase%3A-name"
      echo
      echo " --our-datahub-id | datahub.io's CKAN identifier for this dataset.                       (e.g. melagrid)"
      echo "                  : This id is for use within the namespace http://datahub.io/dataset/<our-datahub-id>."
      echo "                  : see https://github.com/jimmccusker/twc-healthdata/wiki/Listing-twc-healthdata-as-a-LOD-Cloud-Bubble"
      echo
      echo "If the required parameters are not provided, the script will ask for them interactively before installing anything."
      echo "The installer will ask permission before performing each install step, so that you know what it's doing."
      echo
      echo "https://github.com/timrdf/prizms/wiki"
      echo "https://github.com/timrdf/prizms/wiki/Installing-Prizms"
      echo
      exit
   fi

   #echo $PRIZMS_HOME
   #echo $user_home
   #echo $me

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

   project_user_home="${user_home%/*}/$project_user_name"

   i_am_project_user=""
   if [[ "$project_user_name" == `whoami` ]]; then
      i_am_project_user="yes"
   fi

   # Grammar with perspective to developer user about herself or the production user.
   if [[ "$person_user_name" == `whoami` ]]; then
      your="your"
   else
      your="$project_user_name's"
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
      else
         upstream_ckan="none"
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

   #
   our_datahub_id=""
   if [[ "$1" == "--our-datahub-id" ]]; then
      if [[ "$2" != --* ]]; then
         our_datahub_id="$2"
         shift
      fi
      shift
   fi

   div="-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
   function change_source_me {
      echo
      echo "$div `whoami`"
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
      sudo=""
      if [[ $target =~ /etc.* || ( -e "$target" && `stat --format=%U $target` != `whoami` ) ]]; then
         sudo="sudo"
      fi
      if [[ ! -e `dirname $target` ]]; then
         $sudo mkdir -p `dirname $target`
      fi
      if [[ ! -e `dirname $target` ]]; then
         echo "ERROR: could not create `dirname $credentials`"
      fi

      if [[ -n "$new_value" ]]; then
         if [[ -z "`grep $ENVVAR $target 2> /dev/null`" ]]; then
            echo "export $ENVVAR=''" | $sudo tee -a $target
         fi
         current=`$PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/value-of.sh $ENVVAR $target | awk '{print $1}'`
         if [ "$current" != "$new_value" ]; then
            echo
            echo "$ENVVAR is currently set to '$current' in $target"
            echo
            read -p "Q: May we change $ENVVAR to '$new_value' in $target? [y/n] " -u 1 change_it
            echo
            if [[ "$change_it" == [yY] ]]; then
               $sudo $PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/value-of.sh $ENVVAR $target --change-to $new_value
               echo "Okay, we changed $target to:"
               grep "export $ENVVAR=" $target | tail -1
               if [[ ! $target =~ /etc.* ]]; then
                  added="$added $target"
               fi
            else
               echo "Okay, we won't change it. You'll need to change it later$loss."
            fi
         else
            echo "($ENVVAR is already correctly set to '$new_value' in $target)"
         fi
      else
         echo "WARNING: We can't set the $ENVVAR in $target because it is not given."
      fi
   }

   function offer_install_aptget {
      installed=0
      packages="$1"
      reason="$2"
      for package in $packages; do
         echo "The package $package is required to"
         echo "$reason."
         already_there=`dpkg -l | grep "^....$package "` # See what is available: apt-cache search libapache2-mod
         if [[ -z "$already_there" ]]; then
            echo "The $package package needs to be installed, which can be done with the following command:"
            echo
            echo "sudo apt-get install $package"
            echo
            read -p "Q: May we install the package above using the command above? [y/n] " -u 1 install_it
            if [[ "$install_it" == [yY] ]]; then
               echo sudo apt-get install $package
                    sudo apt-get install $package
               installed=1
            fi
         else
            echo "($package is already installed)"
         fi
         echo
      done
      return $installed
   }

   function enable_apache_module {
      enabled=0
      modules="$1"
      reason="$2"
      for module in $modules; do
         echo
         echo "sudo a2enmod $module | grep 'already enabled'"
         echo
         already_enabled=`sudo a2enmod $module 2> /dev/null | grep 'already enabled'`
         # ^^ This enables it before we ask for permission, stating e.g. 'Module proxy_http already enabled' if it already was.
         #    If it was already enabled, nothing to do.
         #    If it wasn't already enabled and we don't get permission, we disable it.
         if [[ -z "$already_enabled" ]]; then # "not already enabled"
            echo "The Apache2 module $module needs to be enabled to"
            echo "$reason."
            echo "The $module module needs to be enabled, which can be done with the following command:"
            echo
            echo "sudo a2enmod $module"
            echo
            read -p "Q: May we enable the module above using the command above? [y/n] " -u 1 enable_it
            if [[ "$enable_it" != [yY] ]]; then
               sudo a2dismod $module # We just previously enabled it (to check), but they don't want it enabled.
               echo "Okay, we won't enable $module."
            else
               enabled=1
            fi
         else
            echo "(module $module is already enabled: $already_enabled)"
         fi
      done
      if [[ "$enabled" == "1" ]]; then
         echo "We enabled $module with: sudo a2enmod $module"
         echo
         read -p "Q: Apache needs to restart for $module to take effect. Restart apache? [y/n] " -u 1 restart_it
         if [[ "$restart_it" == [yY] ]]; then
            sudo service apache2 restart
         else
            echo "Okay, we didn't restart Apache, but you'll need to restart it for $module to take effect."
         fi
      fi
      return $enabled
   }

   function enable_htaccess {
      reason="$1"
      echo
      echo "$div `whoami`"
      target="/etc/apache2/sites-available/default" 
      if [[ -n "$reason" ]]; then
         echo "$reason"
      fi
      echo ".htaccess files only work if the 'AllowOverride All' directive is set in $target, similar to:"
      echo
      echo "    <Directory /var/www/>"
      echo "       AllowOverride All"
      echo "       ..."
      echo
      current=`sudo cat $target | awk '$0 ~ /Directory/ || $0 ~ /AllowOverride/ {print}' | grep -A1 var/www | tail -1 | grep All`
      if [[ -z "$current" ]]; then
         echo "We can change /var/www's AllowOverride to All (it is currently \"$current\"), making the new $target be:"
         echo
         sudo cat $target | awk '{if($1=="<Directory"){scope=$2} if($1=="AllowOverride" && scope=="/var/www/>"){print $1,"All"}else{print}}' > .prizms-apache-config
         cat .prizms-apache-config
         echo
         echo "- - The difference is - -"
         sudo diff $target .prizms-apache-config
         echo
         read -p "Q: May we update $target to enable AllowOverride All for /var/www? [y/n] " -u 1 install_it
         if [[ "$install_it" == [yY] ]]; then
            echo sudo cp $target ${target}_`date +%Y-%m-%d-%H-%M-%S`
                 sudo cp $target ${target}_`date +%Y-%m-%d-%H-%M-%S`
            echo sudo mv .prizms-apache-config $target
                 sudo mv .prizms-apache-config $target
            restart_apache
         else
            echo "Okay, we won't update $target."
         fi
      else
         echo "($target seems to permit .htaccess files for /var/www)"
      fi
   }

   function restart_apache {
      echo
      echo "$div `whoami`"
      echo "Since we've made some changes to apache, we need to restart it so that they take effect."
      echo
      echo sudo service apache2 restart
      echo
      read -p "Q: May we restart apache using the command above? [y/n] " -u 1 restart_it
      if [[ "$restart_it" == [yY] ]]; then
         echo sudo service apache2 restart
              sudo service apache2 restart
      fi
   }

   echo
   echo "Okay, let's install Prizms!"
   echo "   https://github.com/timrdf/prizms/wiki"
   echo "   https://github.com/timrdf/prizms/wiki/Installing-Prizms"

   if [[ -z "$project_user_name" ]]; then
      echo
      echo "First, we need to know about the current user `whoami`."
      read -p "Q: Is `whoami` your project's user name? [y/n] " -u 1 it_is
      if [[ $it_is == [yY] ]]; then
         project_user_name=`whoami`
         echo "Your project's user name is: $project_user_name"
         echo
         echo "$div `whoami`"
         read -p "Q: What is your user name? " -u 1 person_user_name
         echo "Okay, your user name is $person_user_name"
      else
         echo
         echo "$div `whoami`"
         echo "Okay, `whoami` isn't your project's user name."
         read -p "Q: Is `whoami` _your_ user name? [y/n] " -u 1 it_is
         if [[ $it_is == [yY] ]]; then
            # https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD_PUBLISH_VARWWW_ROOT
            person_user_name=`whoami`
            echo "Okay, your user name is $person_user_name."
            echo
            echo "$div `whoami`"
            echo "Prizms should be installed to a user name on this machine created specifically for the project."
            read -p "Q: Does your project have a user name yet? [y/n] " -u 1 it_does
            if [[ $it_does == [yY] ]]; then
               read -p "Q: What is the user name of your project? " -u 1 project_user_name
               if [ ! -e ${user_home%/*}/$project_user_name ]; then
                  echo "ERROR: ${user_home%/*}/$project_user_name does not exist."
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
   echo "$div `whoami`"
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
   echo "$div `whoami`"
   echo "Prizms can pull dataset listings from an installation of CKAN,"
   echo "which can make it easier to gather the datasets that you'd like to integrate."
   echo "It's fine not to pull from a CKAN, so if you don't want to, just leave this blank."
   if [[ -z "$upstream_ckan" ]]; then
      echo
      read -p "Q: Would you like your Prizms to pull dataset listings from an installation of CKAN? [y/n] " -u 1 upstream_ckan
      if [[ -n "$upstream_ckan" || "$upstream_ckan" = [nN] ]]; then
         upstream_ckan=''
         echo "Okay, we'll pull dataset listings from the CKAN $upstream_ckan"
      else
         echo "Okay, we won't bother with CKAN listings."
      fi
   else
      echo "(We'll use the upstream CKAN that you already indicated: $upstream_ckan)"
   fi


   # https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD_CONVERT_PERSON_URI
   if [[ -z $i_am_project_user ]]; then # Running as developer e.g. jsmith not loxd
      echo
      echo "$div `whoami`"
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
   fi

   # https://github.com/timrdf/csv2rdf4lod-automation/wiki/Conversion-process-phase:-name
   echo
   echo "$div `whoami`"
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
   echo "$div `whoami`"
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


   # https://github.com/jimmccusker/twc-healthdata/wiki/Listing-twc-healthdata-as-a-LOD-Cloud-Bubble
   echo
   echo "$div `whoami`"
   echo "Prizms can automatically publish lodcloud-compliant metadata to a CKAN listing at http://datahub.io."
   echo "Enabling this feature allows your Linked Data to be included in the LOD Cloud Diagram."
   echo "See https://github.com/jimmccusker/twc-healthdata/wiki/Listing-twc-healthdata-as-a-LOD-Cloud-Bubble"
   echo "    https://github.com/timrdf/DataFAQs/wiki/CKAN"
   echo "    http://richard.cyganiak.de/2007/10/lod/"
   if [ -z "$our_datahub_id" ]; then
      echo
      read -p "Q: What is the URI of this Prizms' dataset on datahub.io (leave blank if none)? http://datahub.io/dataset/" our_datahub_id
      echo
      if [ -n "$our_datahub_id" ]; then
         echo "Okay, we'll publish lodcloud metadata to http://datahub.io/dataset/$our_datahub_id"
         echo "and store '$our_datahub_id' in CSV2RDF4LOD_PUBLISH_DATAHUB_METADATA_OUR_BUBBLE_ID"
      else
         echo "We won't be able to publish metadata about this installation of Prizms."
      fi
   else
      echo "(We'll use the base URI that you already indicated: $our_datahub_id)"
   fi



   echo
   echo "$div `whoami`"
   echo "$div `whoami`"
   echo "                                    Ready to install"
   echo "$div `whoami`"
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
   if [[ -n "$upstream_ckan" && "$upstream_ckan" != "none" ]]; then
      echo "Your project will pull dataset listings from the CKAN at:  $upstream_ckan"  
   else
      echo "Your project won't pull dataset listings from a CKAN (for now)."
   fi
   echo "Your project's Linked Data base URI is:                    $our_base_uri"
   echo "Your project's source-id is:                               $our_source_id"
   echo "Your project's datahub.io URI is:                          http://datahub.io/dataset/$our_datahub_id"

   project_home=${user_home%/*}/$project_user_name
   PROJECT_PRIZMS_HOME=`echo $PRIZMS_HOME | sed "s/\`whoami\`/$project_user_name/g"`

   echo
   echo "$div `whoami`"
   echo "Okay, we'd like to install prizms at the following locations."
   echo
   echo "  $PRIZMS_HOME/"
   echo "  $PRIZMS_HOME/repos"
   echo
   echo "    ^-- This is where we'll keep the Prizms utilities. Nothing in here will ever be specific to $project_user_name."
   echo "        The repos/ directory will contain a variety of supporting utilities that Prizms uses from other projects."
   echo

   if [[ -z $i_am_project_user ]]; then # Running as developer e.g. jsmith not loxd

   echo "  ~$person_user_name/prizms/$project_user_name"
   echo
   echo "    ^-- This is where you will develop $project_user_name, i.e. your application/instance of Prizms."
   echo "        It will be your working copy of $project_code_repository"
   echo

   fi

   echo "  ~$project_user_name/prizms/$project_user_name"
   echo
   echo "    ^-- This is where the production data and automation is performed and published."
   echo "        The essential bits will be pulled read-only from $project_code_repository"
   echo "        Automation will trigger on those essential bits to organize, describe, retrieve, convert, and publish your Linked Data."
   echo "        To make changes in here, push into $project_code_repository from any working copy (e.g. ~$person_user_name/prizms/$project_user_name)"

   #if [[ -z "$i_am_project_user" && `$PRIZMS_HOME/bin/install/project-user.sh $project_user_name --exists` == "no" ]]; then
   #if [[ -z "$i_am_project_user" && ! -e ${user_home%/*}/$project_user_name ]]; then
   if [[ -z "$i_am_project_user" && ! `grep "^${project_user_name}:" /etc/passwd` ]]; then # Running as developer e.g. jsmith not loxd
      echo
      echo "$div `whoami`"
      echo ${user_home%/*}/$project_user_name
      read -p "Q: Create user $project_user_name? [y/n] " -u 1 install_project_user
      if [[ "$install_project_user" == [yY] ]]; then
         $PRIZMS_HOME/bin/install/project-user.sh $project_user_name
         # TODO:
         # give yourself permission to write cache/ and settings.inc
         # give apache permission to write cache/ and meta/ (and optionally settings.inc.php)
         # Add existing user tony to ftp supplementary/secondary group with usermod command using -a option ~ i.e. add the user to the supplemental group(s). Use only with -G option :
         # sudo usermod -a -G ieeevis `whoami`
      else
         echo "ERROR: We need a user name."
         exit 1
      fi
   fi
   if [[ -z "$i_am_project_user" && ! `grep "^${project_user_name}:" /etc/passwd` ]]; then # Running as developer e.g. jsmith not loxd
      echo "WARNING: $project_user_name was not created."
      exit 1
   fi


   echo
   echo "$div `whoami`"
   echo "Prizms combines a couple other projects, all of which are available on github."
   echo "We'll retrieve those and place them in the directory $PRIZMS_HOME/repos/"
   echo "If they're already there, we'll just update them from the latest on github."
   $PRIZMS_HOME/bin/install/prizms-dependency-repos.sh


   echo "$div `whoami`"
   clone='clone'
   pull='pull'
   if [ "$vcs" == "svn" ]; then
      clone="checkout"
      pull='update'
   fi
   pushd &> /dev/null
      cd
      user_home=`pwd` # e.g. /home/smithj or /home/ieeevis

      if [[ -z "$i_am_project_user" ]]; then # Running as developer e.g. jsmith not loxd
         development="development"
      else
         development="production"
      fi 

      # The local directory that we expect by cloneing $project_code_repository
      target_dir=`basename $project_code_repository`
      target_dir=${target_dir%.*} # e.g. 'ieeevis', 'lofd', etc.

      echo "Now let's install your $development copy of the $project_user_name Prizms."
      echo "(If you already have a working copy there, we'll update it.)" # TODO: recognize when it's already installed.
      echo
      read -p "Q: May we run '$vcs $clone $project_code_repository' from `pwd`/prizms? [y/n] " -u 1 install_it
      if [[ "$install_it" == [yY] ]]; then
         if [[ ! -e prizms ]]; then
            mkdir prizms
         fi
         pushd prizms &> /dev/null

            just_cloned="no"
            if [ ! -e $target_dir ]; then
               if [[ "$vcs" == "git" && -z "`git config --get user.email`" && -n "$person_email" && -z "$i_am_project_user" ]]; then # Running as developer e.g. jsmith not loxd
                  echo
                  echo "$div `whoami`"
                  echo "We can set your email address in your global git configuration using the following command."
                  echo "Doing so will associate your commits to your github account, instead of attributing them to a user named after your machine."
                  echo
                  echo "   git config --global user.email $person_email"
                  echo
                  read -p "Q: May we set your git user.email setting to $person_email using the command above? [y/n] " -u 1 set_it
                  if [[ "$set_it" == [yY] ]]; then
                     git config --global user.email $person_email
                  fi
               fi

               echo
               echo "$div `whoami`"
               echo "GitHub requires that you have an SSH key and that it be registered with them."
               if [[ ! -e $user_home/.ssh/id_dsa.pub && ! -e $user_home/.ssh/id_rsa.pub && -z "$i_am_project_user" ]]; then # Running as developer e.g. jsmith not loxd
                  echo
                  echo "You don't have a ~$person_user_name/.ssh/id_dsa.pub or ~$person_user_name/.ssh/id_rsa.pub,"
                  echo "which could be created using the following command:"
                  echo
                  echo "    ssh-keygen -t dsa -C ${person_email:-'your-email-address'}"
                  echo
                  echo "(If you prefer to set up SSH keys on your own or reuse existing keys, feel free to kill this installer,"
                  echo " go set them up, and rerun this installer using the same arguments as you just used."
                  echo " The installer checks for ~/.ssh/*.pub and will skip this step if it sees them there.)"
                  echo
                  read -p "Q: Would you like to create an SSH key now (using the command above)? [y/n] " genkey
                  if [[ "$genkey" == [yY] ]]; then
                     if [ -z "$person_email" ]; then
                        read -p "Q: We need your email address to set up an SSH key. What is it? " person_email
                     fi
                     if [ -n "$person_email" ]; then
                        echo ssh-keygen -t dsa -C $person_email
                             ssh-keygen -t dsa -C $person_email
                     else
                        echo "WARNING `basename $0` needs an email address to set up an SSH key."
                     fi
                  else
                     echo "We didn't do anything to create an SSH key."
                  fi
                  if [ -e $user_home/.ssh/id_dsa.pub ]; then
                     echo
                     echo "$div `whoami`"
                     echo "Great! You have a shiny new SSH key."
                     if [ "$vcs" == "git" ]; then
                        echo "Go add the following to https://github.com/settings/ssh"
                        cat $user_home/.ssh/id_dsa.pub
                        echo
                        read -p "Q: Finished adding your key? Once you do, we'll try running this install script again. Ready? [y] " finished
                        $me --me             $person_uri              \
                            --my-email       $person_email            \
                            --proj-user      $project_user_name       \
                            --repos          $project_code_repository \
                            --upstream-ckan  $upstream_ckan           \
                            --our-base-uri   $our_base_uri            \
                            --our-source-id  $our_source_id           \
                            --our-datahub-id $our_datahub_id
                        # ^ Recursive call
                     fi
                  fi
               else
                  echo "(You have a .ssh/*.pub; be sure to register it with GitHub. See https://help.github.com/articles/generating-ssh-keys)"
               fi

               # When the project user:
               # Your configuration specifies to merge with the ref 'master'
               # from the remote, but no such ref was fetched.
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
               elif [ "$status" -ne 0 ]; then
                  echo "We're not sure what happended; $vcs returned $status"
               else
                  echo "Okay, $project_code_repository is now ${clone}'d to $dir." 
               fi
               just_cloned="yes"
            fi # ! -e $target_dir
            if [[ -e $target_dir ]]; then
               pushd $target_dir &> /dev/null

                  if [[ -z "$i_am_project_user" ]]; then
                     echo "#!/bin/bash"                                                  > .refresh-prizms-installation
                     echo "if [[ \"\$1\" == "pull" ]]; then"                            >> .refresh-prizms-installation
                     echo "   pushd /home/$person_user_name/opt/prizms; git pull; popd" >> .refresh-prizms-installation
                     echo "fi"                                                          >> .refresh-prizms-installation
                     echo "$me \\"                                                      >> .refresh-prizms-installation
                     echo "    --me             $person_uri              \\"            >> .refresh-prizms-installation
                     #echo "    --my-email       $person_email            \\"           >> .refresh-prizms-installation
                     echo "    --proj-user      $project_user_name       \\"            >> .refresh-prizms-installation
                     echo "    --repos          $project_code_repository \\"            >> .refresh-prizms-installation
                     echo "    --upstream-ckan  $upstream_ckan           \\"            >> .refresh-prizms-installation
                     echo "    --our-base-uri   $our_base_uri            \\"            >> .refresh-prizms-installation
                     echo "    --our-source-id  $our_source_id           \\"            >> .refresh-prizms-installation
                     echo "    --our-datahub-id $our_datahub_id"                        >> .refresh-prizms-installation
                     chmod +x .refresh-prizms-installation
                  fi

                  if [[ "$just_cloned" != "yes" ]]; then
                     echo
                     echo "$project_code_repository is already ${clone}'d into $target_dir; ${pull}'ing it..."
                     $vcs $pull
                  fi

                  added=''

                  if [[ -z "$i_am_project_user" && \
                       ( ! -e data/source/ || ! -e lodspeakr/ || ! -e doc/ || ! -e 'data/faqs/example-1/faqt-brick' ) ]]; then # Running as developer e.g. jsmith not loxd
                     echo
                     echo "$div `whoami`"
                     echo "Prizms reuses the directory conventions that csv2rdf4lod-automation uses."
                     echo "Following these conventions aids uniformity across many projects' offerings."
                     echo "For more, see https://github.com/timrdf/csv2rdf4lod-automation/wiki/Directory-Conventions"
                     echo
                     echo `pwd`/data/source/
                     echo `pwd`/data/faqs/example-1/faqt-brick
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
                        for directory in doc lodspeakr 'data/faqs/example-1/faqt-brick' ; do
                           if [ ! -e $directory ]; then
                              added="$added $directory"
                              echo "Creating `pwd`/$directory"
                              mkdir -p $directory
                           fi
                        done
                     fi
                  fi
                

                  # Add .gitignore with "*" in data/source/.gitignore
                  target="data/source/.gitignore"
                  if [[ ! -e $target && -z "$i_am_project_user" ]]; then # Running as developer e.g. jsmith not loxd
                     echo
                     echo "It's a good practice to include a .gitignore in your data/source directory, so that you do not accidentally commit and push large data files into your repository."
                     echo
                     read -p "Q: May we add $target? [y/n] " -u 1 make_it
                     if [[ "$make_it" == [yY] ]]; then
                        echo "*"                             > $target
                        added="$added data/source/.gitignore"
                     fi
                  fi
                  if [[ ! -e .gitignore || ! `grep "^.refresh-prizms-installation" $target` && -z "$i_am_project_user" ]]; then
                     echo ".refresh-prizms-installation" >> .gitignore
                     added="$added .gitignore"
                  fi

                  # Set shell environment variable values in source-me.sh's.
                  if [[ -z "$i_am_project_user" ]]; then  # Running as developer e.g. jsmith not loxd
                     # Done by development user, NOT project user.

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
                        echo "$div `whoami`"
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
                     # Set CSV2RDF4LOD_BASE_URI (to $our_base_uri) in the project-level source-me.sh.
                     #
                     change_source_me $target CSV2RDF4LOD_BASE_URI "$our_base_uri" \
                        'indicate the Linked Data base URI to use for all datasets that it creates' \
                        'https://github.com/timrdf/csv2rdf4lod-automation/wiki/Conversion-process-phase:-name' \
                        'some loss'

                     #
                     # Set CSV2RDF4LOD_CKAN_SOURCE (to $upstream_ckan) in the project-level source-me.sh.
                     #
                     if [[ "$upstream_ckan" == http* && -e "$target" ]]; then
                        echo
                        echo "$div `whoami`"
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

                     # Set CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID (to $our_source_id) in the project-level source-me.sh.
                     change_source_me $target CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID "$our_source_id" \
                        'indicate the source identifier for all datasets that it creates on its own' \
                        'https://github.com/timrdf/csv2rdf4lod-automation/wiki/Aggregating-subsets-of-converted-datasets' \
                        'in order for Prizms to create useful Linked Data URIs'

                     # Set CSV2RDF4LOD_PUBLISH_ANNOUNCE_TO_SINDICE (to 'true') in the project-level source-me.sh.
                     change_source_me $target CSV2RDF4LOD_PUBLISH_ANNOUNCE_TO_SINDICE true \
                        'determine if it should announce each newly converted dataset to http://sindice.com/main/submit' \
                        'https://github.com/timrdf/csv2rdf4lod-automation/wiki/Ping-the-Semantic-Web' \
                        'some loss'

                     # Set CSV2RDF4LOD_PUBLISH_ANNOUNCE_TO_PTSW (to 'false') in the project-level source-me.sh.
                     change_source_me $target CSV2RDF4LOD_PUBLISH_ANNOUNCE_TO_PTSW false \
                        'determine if it should announce each newly converted dataset to pingthesemanticweb.com' \
                        'https://github.com/timrdf/csv2rdf4lod-automation/wiki/Ping-the-Semantic-Web' \
                        'some loss'

                     # Set CSV2RDF4LOD_PUBLISH_DATAHUB_METADATA  (to 'true') in the project-level source-me.sh.
                     change_source_me $target CSV2RDF4LOD_PUBLISH_DATAHUB_METADATA true \
                        'determine if it should update its datahub.io CKAN listing for the http://datahub.io/group/lodcloud group' \
                        'https://github.com/jimmccusker/twc-healthdata/wiki/Listing-twc-healthdata-as-a-LOD-Cloud-Bubble' \
                        'some loss'

                     # Set CSV2RDF4LOD_PUBLISH_DATAHUB_METADATA_OUR_BUBBLE_ID (to $our_datahub_id) in the project-level source-me.sh.
                     change_source_me $target CSV2RDF4LOD_PUBLISH_DATAHUB_METADATA_OUR_BUBBLE_ID "$our_datahub_id" \
                        "indicate which datahub.io CKAN entry to update (i.e. http://datahub.io/dataset/$our_datahub_id) for this installation of Prizms" \
                        'https://github.com/jimmccusker/twc-healthdata/wiki/Listing-twc-healthdata-as-a-LOD-Cloud-Bubble' \
                        'some loss'

                     # Set DATAFAQS_HOME in the project-level source-me.sh.
                     target="data/faqs/datafaqs-source-me.sh"
                     change_source_me $target DATAFAQS_HOME "$PRIZMS_HOME/repos/DataFAQs" \
                        'find the scripts that DataFAQs needs to run' \
                        'https://github.com/timrdf/DataFAQs/wiki/DATAFAQS-environment-variables' \
                        'running DataFAQs will fail'

                     # Set DATAFAQS_BASE_URI in the project-level source-me.sh.
                     change_source_me $target DATAFAQS_BASE_URI "$our_base_uri" \
                        'situate the URIs created by DataFAQs within a namespace that we control' \
                        'https://github.com/timrdf/DataFAQs/wiki/DATAFAQS-environment-variables' \
                        'URIs will not be valid Linked Data'

                     # DATAFAQS_PROVENANCE_CODE_RAW_BASE  beginning part of:
                     #   https://raw.github.com/timrdf/DataFAQs/master/services/sadi/faqt/datascape/size.py
                     #                                                 services/sadi/faqt/datascape <------- "servicePath"
                     #
                     # DATAFAQS_PROVENANCE_CODE_PAGE_BASE beginning part of:
                     #   https://github.com/timrdf/DataFAQs/blob/master/services/sadi/faqt/datascape/size.py
                     #                                                                               size <-- "serviceNameText"
                     #
                     # bin/install/prizms-dependency-repos.sh encapsulates       'git://github.com/timrdf/DataFAQs.git' 
                     #
                     # Note: if we generalize which DataFAQs repository we use, 
                     #       we need to changebin/install/prizms-dependency-repos.sh AND 
                     #       the two hard-coded values below:

                     # Set DATAFAQS_PROVENANCE_CODE_RAW_BASE in the project-level source-me.sh.
                     change_source_me $target DATAFAQS_PROVENANCE_CODE_RAW_BASE 'https://raw.github.com/timrdf/DataFAQs/master' \
                        'situate the URIs created by DataFAQs within a namespace that we control' \
                        'https://github.com/timrdf/DataFAQs/wiki/DATAFAQS-environment-variables' \
                        'URIs will not be valid Linked Data'

                     # Set DATAFAQS_PROVENANCE_CODE_PAGE_BASE in the project-level source-me.sh.
                     change_source_me $target DATAFAQS_PROVENANCE_CODE_PAGE_BASE 'https://github.com/timrdf/DataFAQs/blob/master' \
                        'situate the URIs created by DataFAQs within a namespace that we control' \
                        'https://github.com/timrdf/DataFAQs/wiki/DATAFAQS-environment-variables' \
                        'URIs will not be valid Linked Data'


                     # Repeat the three above for /etc/apache2/envvars
                     echo
                     echo "$div `whoami`"
                     target='/etc/apache2/envvars'
                     echo "Prizms includes additional PROV-O assertions about SADI services in the description they return upon HTTP GET requests"
                     change_source_me $target DATAFAQS_BASE_URI "$our_base_uri" \
                        'situate the URIs created by DataFAQs within a namespace that we control' \
                        'https://github.com/timrdf/DataFAQs/wiki/DATAFAQS-environment-variables' \
                        'URIs will not be valid Linked Data'
                     change_source_me $target DATAFAQS_PROVENANCE_CODE_RAW_BASE 'https://raw.github.com/timrdf/DataFAQs/master' \
                        'situate the URIs created by DataFAQs within a namespace that we control' \
                        'https://github.com/timrdf/DataFAQs/wiki/DATAFAQS-environment-variables' \
                        'URIs will not be valid Linked Data'
                     change_source_me $target DATAFAQS_PROVENANCE_CODE_PAGE_BASE 'https://github.com/timrdf/DataFAQs/blob/master' \
                        'situate the URIs created by DataFAQs within a namespace that we control' \
                        'https://github.com/timrdf/DataFAQs/wiki/DATAFAQS-environment-variables' \
                        'URIs will not be valid Linked Data'



                     # ON MACHINE
                     # (machine-level source-me.sh)
                     #
                     template="$PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/conversion-root-stub/source/csv2rdf4lod-source-me-on-yyy.sh"
                     target="data/source/csv2rdf4lod-source-me-on-$project_user_name.sh"
                     if [[ ! -e $target ]]; then
                        cp $template $target
                        added="$added $target"
                        # TODO: export CSV2RDF4LOD_CONVERT_MACHINE_URI="http://tw.rpi.edu/web/inside/machine/aquarius#melagrid"
                        echo
                        echo "$div `whoami`"
                        echo "There wasn't a source-me.sh for your machine in the data conversion root, so we created one for you at $target"
                     fi




                     # AS DEVELOPER
                     # (developer-user-level source-me.sh)
                     #
                     # Create a stub for the user-level environment variables, based on the template available from the csv2rdf4lod-automation.
                     # See https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD-environment-variables-%28considerations-for-a-distributed-workflow%29
                     # 
                     template="$PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/conversion-root-stub/source/csv2rdf4lod-source-me-as-xxx.sh"
                     target="data/source/csv2rdf4lod-source-me-as-$person_user_name.sh"
                     if [[ ! -e $target ]]; then
                        # TODO: add source ../csv2rdf4lod-source-me-for-<project>.sh to as-<developer>.sh (not appearing in some cases)
                        cp $template $target
                        echo "source `pwd`/data/source/csv2rdf4lod-source-me-for-$project_user_name.sh"              >> $target
                        $PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/value-of.sh 'CSV2RDF4LOD_CONVERT_PERSON_URI' $target --change-to $person_uri
                        added="$added $target"
                        echo
                        echo "$div `whoami`"
                        echo "There wasn't a source-me.sh for your user name in the data conversion root, so we created one for you at $target"
                     fi


                     # AS PROJECT
                     # (project-user-level source-me.sh)
                     #
                     # csv2rdf4lod-source-me-as-${project_user_name}.sh is *the* one and only source-me.sh that 
                     # the project name should source when initializing -- particular when from a cronjob.
                     # This is *the* only source-me.sh that should appear in the project user name's ~/.bashrc
                     #
                     # This is created by the developer -- NOT the project user -- and committed to version control.
                     template="$PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/conversion-root-stub/source/csv2rdf4lod-source-me-as-xxx.sh"
                     target="data/source/csv2rdf4lod-source-me-as-$project_user_name.sh"
                     if [[ ! -e $target ]]; then
                        cat $template | grep -v 'export CSV2RDF4LOD_CONVERT_PERSON_URI='                                                           > $target
                        echo "source `pwd | sed "s/\`whoami\`/$project_user_name/g"`/data/source/csv2rdf4lod-source-me-for-$project_user_name.sh" >> $target
                        echo "source `pwd | sed "s/\`whoami\`/$project_user_name/g"`/data/source/csv2rdf4lod-source-me-credentials.sh"            >> $target
                        # any others to source?
                        added="$added $target"
                        echo
                        echo "$div `whoami`"
                        echo "There wasn't a source-me.sh for your project's user name in the data conversion root, so we created one for you at $target"
                     fi

                     project_data_root="${user_home%/*}/$project_user_name/prizms/$target_dir/data/source" # TODO: reconcile - what does this impact?
                     change_source_me $target CSV2RDF4LOD_CONVERT_DATA_ROOT "$project_data_root" \
                        "indicate the production data directory, from which /var/www and the production SPARQL endpoints are loaded" \
                        'https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD_CONVERT_DATA_ROOT' \
                        'some loss'

                     change_source_me $target CSV2RDF4LOD_PUBLISH_VARWWW_DUMP_FILES true \
                        "enable publishing RDF dump files to the htdocs directory, so they may be used to load the SPARQL endpoint" \
                        'https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD-environment-variables' \
                        'unable to publish RDF dump files, and unable to load the SPARQL endpoint'

                     #if [[ `value-of.sh CSV2RDF4LOD_PUBLISH_VARWWW_DUMP_FILES $target` == "true" ]]; then
                     change_source_me $target CSV2RDF4LOD_PUBLISH_VARWWW_ROOT "/var/www" \
                        "indicate the htdocs directory to publish RDF dump files to, which are used to load the SPARQL endpoint" \
                        'https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD_PUBLISH_VARWWW_ROOT' \
                        'unable to publish RDF dump files, and unable to load the SPARQL endpoint'
                     #fi


                     # AS DEVELOPER
                     # alias: Developer su'ing to Project user name
                     echo
                     echo "$div `whoami`"
                     new_command="alias $project_user_name='sudo su $project_user_name'" # e.g. alias hd='sudo su healthdata'
                     target="data/source/csv2rdf4lod-source-me-as-$person_user_name.sh"
                     echo "As a developer of this $project_user_name Prizms, you will need to change into the $project_user_name user"
                     echo "to convert and publish datasets. You can use an alias to this:"
                     echo
                     echo "   $new_command"
                     already_there=`grep "$new_command" $target` 
                     echo
                     if [ -n "$already_there" ]; then
                        echo "It seems that you already have the following in your $target, so we won't offer to add it again:"
                        echo
                        echo $already_there
                     else
                        read -p "Add this command to your $target? [y/n] " -u 1 install_it
                        if [[ "$install_it" == [yY] ]]; then
                           echo $new_command >> $target
                           echo
                           echo "Okay, we added it:"
                           grep "$new_command" $target
                           added="$added $target"
                        else
                           echo "We didn't change your $target, so you'll need to make sure you set the paths correctly each time."
                        fi
                     fi


                     # AS both DEVELOPER and PROJECT USER
                     for user in $person_user_name $project_user_name; do

                        target="data/source/csv2rdf4lod-source-me-as-$user.sh"

                        #
                        # Add PATH = PATH + sitaute paths to data/source/csv2rdf4lod-source-me-as-$user.sh
                        #
                        echo
                        echo "$div `whoami`"
                        set_paths_cmd=`$PRIZMS_HOME/bin/install/paths.sh --help | tail -1 | sed 's/^ *//' | sed "s/\`whoami\`/$user/g"`
                        echo "The following command adds into $your shell environment the paths that Prizms requires to run its scripts."
                        echo "Running it multiple times will have no effect, since only the missing paths are added."
                        echo "For details, see https://github.com/timrdf/csv2rdf4lod-automation/wiki/situate-shell-paths-pattern"
                        echo "The following command should appear in $your data/source/csv2rdf4lod-source-me-as-$user.sh."
                        echo
                        echo "    $set_paths_cmd"
                        already_there=`grep ".*export PATH=.*prizms/bin/install/paths.sh.*" $target`
                        echo
                        if [ -n "$already_there" ]; then
                           echo "It seems that you already have the following in $your $target, so we won't offer to add it again:"
                           echo
                           echo $already_there
                        else
                           read -p "Add this command to $your $target? [y/n] " -u 1 install_it
                           if [[ "$install_it" == [yY] ]]; then
                              echo $set_paths_cmd >> $target
                              echo
                              echo "Okay, we added it:"
                              grep ".*export PATH=.*prizms/bin/install/paths.sh.*" $target
                              added="$added $target"
                           else
                              echo "We didn't change $your $target, so you'll need to make sure you set the paths correctly each time."
                           fi
                        fi

                        #
                        # Add CLASSPATH = CLASSPATH + sitaute paths to data/source/csv2rdf4lod-source-me-as-$user.sh
                        #
                        echo
                        echo "$div `whoami`"
                        set_paths_cmd=`$PRIZMS_HOME/bin/install/classpaths.sh --help | tail -1 | sed 's/^ *//' | sed "s/\`whoami\`/$user/g"`
                        echo "The following command adds into $your shell environment the Java class paths that Prizms requires to run its scripts."
                        echo "Just like the previous paths.sh command, running this multiple times will have no effect, since only the missing paths are added."
                        echo "For details, see https://github.com/timrdf/csv2rdf4lod-automation/wiki/situate-shell-paths-pattern"
                        echo "The following command should appear in $your data/source/csv2rdf4lod-source-me-as-$user.sh."
                        echo
                        echo "    $set_paths_cmd"
                        already_there=`grep ".*export CLASSPATH=.*prizms/bin/install/classpaths.sh.*" $target`
                        echo
                        if [ -n "$already_there" ]; then
                           echo "It seems that you already have the following in $your $target, so we won't offer to add it again:"
                           echo
                           echo $already_there
                        else
                           read -p "Add this command to $your $target? [y/n] " -u 1 install_it
                           if [[ "$install_it" == [yY] ]]; then
                              echo $set_paths_cmd >> $target
                              echo
                              echo "Okay, we added it:"
                              grep ".*export CLASSPATH=.*prizms/bin/install/classpaths.sh.*" $target
                              added="$added $target"
                           else
                              echo "We didn't change $your $target, so you'll need to make sure you set the paths correctly each time."
                           fi
                        fi

                        # Set CSV2RDF4LOD_HOME
                        change_source_me $target CSV2RDF4LOD_HOME "`echo $PRIZMS_HOME/repos/csv2rdf4lod-automation | sed "s/\`whoami\`/$user/g"`" \
                           "Ensure that all of the csv2rdf4lod-automation scripts can call each other." \
                           'https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD-not-set' \
                           'unable to invoke some scripts'

                        echo
                        echo "$div `whoami`"
                        echo "The n3.vim configuration can enable syntax highlighting for the Turtle syntax."
                        echo "see http://www.vim.org/scripts/script.php?script_id=944 for details to see how to modify:"
                        echo
                        echo "  $user_home/.vim/syntax/n3.vim and"
                        echo "  $user_home/.vim/filetype.vim"
                        echo
                        if [[ ! -e $user_home/.vim/syntax/n3.vim ]]; then
                           read -p "Q: Enable syntax highlighting in vi with n3.vim? [y/n] " -u 1 install_it
                           if [[ "$install_it" == [yY] ]]; then
                              mkdir -p $user_home/.vim/syntax
                              curl --progress-bar -L 'http://www.vim.org/scripts/download_script.php?src_id=6882' > $user_home/.vim/syntax/n3.vim

                              echo " \"RDF Notation 3 Syntax"                                      > $user_home/.vim/filetype.vim
                              echo "    augroup filetypedetect"                                   >> $user_home/.vim/filetype.vim
                              echo "        au BufNewFile,BufRead *.n3  setfiletype n3"           >> $user_home/.vim/filetype.vim
                              echo "        au BufNewFile,BufRead *.ttl  setfiletype n3"          >> $user_home/.vim/filetype.vim
                              echo "        au BufNewFile,BufRead *.trig  setfiletype n3"         >> $user_home/.vim/filetype.vim
                              echo "    augroup END "                                             >> $user_home/.vim/filetype.vim
                           else
                              echo "Okay, we didn't change anything."
                           fi
                        else
                           echo "(vi Turtle syntax highlighting seems to be already installed)"
                        fi
                     done # PATH, CLASSPATH, and JENAROOT for person and project users.


                     # NOTE sudo vi /etc/passwd change <project-user>'s shell from /bin/sh to /bin/bash


                     # CSV2RDF4LOD_PUBLISH_VIRTUOSO and CSV2RDF4LOD_PUBLISH_SUBSET_SAMPLES are set below, after we know that Virtuoso is installed.

                  fi # end "I am not project user"

                  #
                  # Add source data/source/csv2rdf4lod-source-me-as-$person_user_name.sh to ~/.bashrc
                  #
                  echo
                  echo "$div `whoami`"
                  source_me="source `pwd`/data/source/csv2rdf4lod-source-me-as-`whoami`.sh"
                  echo "Prizms encapsulates all of the environment variables and PATH setup that is needed within"
                  echo "a single source-me.sh script dedicated to the user that needs it. The script is version-controlled"
                  echo "so we can manage the environment variables that everybody uses. The single source-me.sh should be the *only*"
                  echo "source-me.sh that is called from your ~/.bashrc. The following command is the only"
                  echo "source-me.sh that you need to run, and should be placed within your ~/.bashrc."
                  echo
                  echo "   $source_me"
                  if [[ -e ~/.bashrc ]]; then
                     already_there=`grep ".*source \`pwd\`/data/source/csv2rdf4lod-source-me-as-\`whoami\`.sh.*" ~/.bashrc`
                  else
                     already_there=""
                  fi
                  echo
                  if [ -n "$already_there" ]; then
                     echo "It seems that you already have the following in your ~/.bashrc, so we won't offer to add it again:"
                     echo
                     echo $already_there
                  else
                     see="https://github.com/timrdf/csv2rdf4lod-automation/wiki/Script:-source-me.sh"
                     read -p "Add this command to your ~/.bashrc? [y/n] " -u 1 install_it
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

                  # End setting the environment variables for project, project user, and developer user.






                  #
                  # Start installing dependencies.
                  #
                  if [[ -z "$i_am_project_user" ]]; then  # Running as developer e.g. jsmith not loxd

                     #
                     # We need to check the /etc/hosts before we try to install Virtuoso as a dependency,
                     # otherwise dpkg will fail to build it when called by csv2rdf4lod-automation's install-dependencies.sh.
                     #
                     echo
                     echo "$div `whoami`"
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
                        read -p "Q: May we make the change to $target? [y/n] " -u 1 change_it
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
                  fi # end running as developer e.g. jsmith not loxd

                  avoid_sudo="--avoid-sudo"
                  use_sudo=""
                  if [[ -z "$i_am_project_user" ]]; then  # Running as developer e.g. jsmith not loxd
                     avoid_sudo=""
                     use_sudo="--use-sudo"
                  fi
                  #if [[ -z "$i_am_project_user" ]]; then  # Running as developer e.g. jsmith not loxd # TODO: this should be removed in favor of $avoid_sudo
                     #
                     # Install third party utilities (mostly with apt-get and tarball installs).
                     #
                     echo
                     echo "$div `whoami`"
                     echo "Prizms uses a variety of third party utilities that we can try to install for you automatically."
                     echo "The following utilities seem to already be installed okay:"
                     echo
                     $PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/install-csv2rdf4lod-dependencies.sh -n $avoid_sudo $use_sudo | grep "^.okay"
                     $PRIZMS_HOME/repos/DataFAQs/bin/install-datafaqs-dependencies.sh                       -n $avoid_sudo $use_sudo | grep "^.okay"
                     # TODO: set up the user-based install that does NOT require sudo. python's easy_install
                   
                     todo=`$PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/install-csv2rdf4lod-dependencies.sh -n $avoid_sudo $use_sudo | grep "^.TODO" | grep -v "pydistutils.cfg"`
                     todo=$todo`$PRIZMS_HOME/repos/DataFAQs/bin/install-datafaqs-dependencies.sh                  -n $avoid_sudo $use_sudo | grep "^.TODO" | grep -v "pydistutils.cfg"`
                     if [ -n "$todo" ]; then
                        echo
                        echo "However, the following do not seem to be installed:"
                        echo
                        $PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/install-csv2rdf4lod-dependencies.sh -n $avoid_sudo $use_sudo | grep "^.TODO" | grep -v "pydistutils.cfg"
                        $PRIZMS_HOME/repos/DataFAQs/bin/install-datafaqs-dependencies.sh                       -n $avoid_sudo $use_sudo | grep "^.TODO" | grep -v "pydistutils.cfg"
                        echo
                        read -p "Q: May we try to install the dependencies listed above? (We'll need root for most of them) [y/n] " -u 1 install_them
                        echo
                        if [[ "$install_them" == [yY] ]]; then
                           touch .before-prizms-installed-dependencies
                           $PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/install-csv2rdf4lod-dependencies.sh $avoid_sudo $use_sudo 2> /dev/null
                           $PRIZMS_HOME/repos/DataFAQs/bin/install-datafaqs-dependencies.sh                       $avoid_sudo $use_sudo
                        else
                           echo "Okay, we won't try to install them. Check out the following if you want to do it yourself:"
                           echo "  https://github.com/timrdf/csv2rdf4lod-automation/wiki/Installing-csv2rdf4lod-automation---complete"
                        fi
                     fi
                     rm -f .before-prizms-installed-dependencies
                  #fi # end running as developer e.g. jsmith not loxd # # TODO: this should be removed in favor of $avoid_sudo

                  if [[ -z "$i_am_project_user" ]]; then  # Running as developer e.g. jsmith not loxd

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
                        echo "$div `whoami`"
                        target="/var/lib/virtuoso/db/virtuoso.ini"
                        data_root=`cd; echo ${PWD%/*}`/$project_user_name/prizms/$target_dir/data/
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

                        credentials="/etc/prizms/$project_user_name/triple-store/virtuoso/csv2rdf4lod-source-me-for-virtuoso-credentials.sh"
                        if [[ -e $credentials ]]; then
                           vpw=`$PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/value-of.sh 'CSV2RDF4LOD_PUBLISH_VIRTUOSO_PASSWORD' $credentials`
                        fi
                        if [[ -z "$vpw" ]]; then
                           echo
                           echo "$div `whoami`"
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

                        echo
                        echo "$div `whoami`"
                        offer_install_aptget \
                           'libapache2-mod-proxy-html' \
                           "expose the (port 8890) Virtuoso server at the URL $our_base_uri/sparql and the (port 8080) Tomcat application server of SADI services at $our_base_uri/sadi-services"

                        echo "$div `whoami`"
                        enable_apache_module 'proxy_http' "expose your (port 8890) Virtuoso server at the URL $our_base_uri/sparql"
                        #                  ^ 'proxy' module is enabled when proxy_http is enabled.

                        #
                        # The apache directives to map the proxy seems to always change.
                        #
                        # Mapping 1: See https://github.com/jimmccusker/twc-healthdata/wiki/VM-Installation-Notes#wiki-virtuoso
                        #
                        # Mapping 2:
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
                        # Mapping 3: works on melagrid.
                        #
                        #  <Location /sparql>
                        #     allow from all
                        #     SetHandler None
                        #     Options +Indexes
                        #     ProxyPass               http://localhost:8890/sparql
                        #     ProxyPassReverse        /sparql
                        #     ProxyHTMLExtended On
                        #    #ProxyHTMLEnable         On
                        #     ProxyHTMLURLMap url\(/([^\)]*)\) url(/sparql$1) Rihe
                        #     ProxyHTMLURLMap         /sparql /sparql
                        #     ProxyHTMLURLMap         http://localhost:8890/sparql /sparql
                        #  </Location>
                        # 
                        # https://scm.escience.rpi.edu/trac/ticket/1502#comment:5 (sparql only)
                        # https://scm.escience.rpi.edu/trac/ticket/1612#comment:2 (sparql AND sadi-services)
                        #
                        # Mapping 4: works on ieeevis VM (but needed to be updated to work along side sadi-services https://scm.escience.rpi.edu/trac/ticket/1612#comment:2)
                        #
                        #  # https://scm.escience.rpi.edu/trac/ticket/1502#comment:5
                        #  ProxyTimeout 1800
                        #  ProxyRequests Off
                        #  ProxyPass /sparql http://localhost:8890/sparql
                        #  <Location /sparql>
                        #          ProxyPassReverse /
                        #          RequestHeader unset Accept-Encoding
                        #          Order allow,deny
                        #          allow from all
                        #  </Location>
                        #
                        # Mapping 5: works on datafaqstest and lofd (updated to work along side Tomcat).
                        #
                        #  ProxyTimeout 1800
                        #  ProxyRequests Off
                        #
                        #  ProxyPass /sparql http://localhost:8890/sparql
                        #  ProxyPassReverse /sparql http://localhost:8890/sparql
                        #  <Location /sparql>
                        #        Order allow,deny
                        #        allow from all
                        #        ProxyHTMLURLMap / /sparql/ c
                        #        SetOutputFilter proxy-html
                        #  </Location>
 
                        echo # (This Apache-config modification pattern is repeated below for Tomcat)
                        echo "$div `whoami`"
                        target='/etc/apache2/sites-available/default'
                        already_there=""
                        if [ -e $target ]; then
                           already_there=`grep 'Location /sparql' $target`
                        fi
                        echo "Some Apache directives (e.g., ProxyPass) need to be set in $target to expose your (port 8890) Virtuoso server at the URL $our_base_uri/sparql."
                        if [[ -z "$already_there" ]]; then
                           echo "To expose the Virtuoso server on port 8890 at $our_base_uri/sparql,"
                           echo "the following apache configuration needs to be set in $target:"
                           echo                                                                       # Mapping 5 (see above)
                           echo '  ProxyTimeout 1800'                                                > .prizms-apache-conf
                           echo '  ProxyRequests Off'                                               >> .prizms-apache-conf
                           echo                                                                     >> .prizms-apache-conf
                           echo '  ProxyPass /sparql http://localhost:8890/sparql'                  >> .prizms-apache-conf
                           echo '  ProxyPassReverse /sparql http://localhost:8890/sparql'           >> .prizms-apache-conf
                           echo '  <Location /sparql>'                                              >> .prizms-apache-conf
                           echo '          Order allow,deny'                                        >> .prizms-apache-conf
                           echo '          allow from all'                                          >> .prizms-apache-conf
                           echo '          ProxyHTMLURLMap / /sparql/ c'                            >> .prizms-apache-conf
                           echo '          SetOutputFilter proxy-html'                              >> .prizms-apache-conf
                           echo '  </Location>'                                                     >> .prizms-apache-conf
                           cat .prizms-apache-conf

                           # Tuck the new directives into the entire configuration file.
                           virtualhost=`sudo  grep    "</VirtualHost>" $target`
                           sudo cat $target | grep -v "</VirtualHost>" > .apache-conf
                           cat .prizms-apache-conf                    >> .apache-conf
                           echo                                       >> .apache-conf
                           echo $virtualhost                          >> .apache-conf
                           echo
                           echo The final configuration file will look like:
                           echo
                           cat .apache-conf
                           read -p "Q: May we add the directives above to $target? [y/n] " -u 1 install_it
                           if [[ "$install_it" == [yY] ]]; then
                              sudo cp $target .$target_`date +%Y-%m-%d-%H-%M-%S`
                              #cat .prizms-apache-conf | sudo tee -a $target &> /dev/null
                              sudo mv .apache-conf $target
                              restart_apache
                           fi
                        else
                           echo "($target seems to already contain the ProxyPath directives to map /sparql to 8890)"
                        fi

                        # Adding the following to /etc/vservers/.httpd/ieeevis.conf avoids http://lofd.tw.rpi.edu falling into VM host.
                        #    Redirect permanent /projects/ieeevis /projects/ieeevis/

                        target="data/source/csv2rdf4lod-source-me-for-$project_user_name.sh"

                        # Set CSV2RDF4LOD_PUBLISH_SPARQL_ENDPOINT (project-wide)
                        change_source_me $target CSV2RDF4LOD_PUBLISH_SPARQL_ENDPOINT $our_base_uri/sparql \
                           'permit Prizms to query the data that is has loaded for subsequent processing' \
                           'https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD-environment-variables' \
                           'some loss'

                        # Set CSV2RDF4LOD_PUBLISH_VIRTUOSO_SPARQL_ENDPOINT (project-wide)
                        change_source_me $target CSV2RDF4LOD_PUBLISH_VIRTUOSO_SPARQL_ENDPOINT $our_base_uri/sparql \
                           'indicate the external URL for the SPARQL endpoint for provenance purposes' \
                           'https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD_PUBLISH_VIRTUOSO_SPARQL_ENDPOINT' \
                           'will not correctly capture the provenance of named graph loads in the SPARQL endpoint'

                     fi # end $virtuoso_installed
                     rm -f .prizms-apache-conf
                  fi # end running as developer e.g. jsmith not loxd

                  if [[ -z "$i_am_project_user" ]]; then  # Running as developer e.g. jsmith not loxd

                     target="data/source/csv2rdf4lod-source-me-as-$project_user_name.sh"

                     # set CSV2RDF4LOD_PUBLISH_VIRTUOSO true (ONLY for project user)
                     change_source_me $target CSV2RDF4LOD_PUBLISH_VIRTUOSO true \
                        "enable loading the RDF dump files in the htdocs directory ($www/source) into the SPARQL endpoint" \
                        'https://github.com/timrdf/csv2rdf4lod-automation/wiki/Publishing-conversion-results-with-a-Virtuoso-triplestore' \
                        'unable to load the SPARQL endpoint'

                     # set CSV2RDF4LOD_PUBLISH_SUBSET_SAMPLES true (ONLY for project user)
                     change_source_me $target CSV2RDF4LOD_PUBLISH_SUBSET_SAMPLES true \
                        "enable loading the *small* sample portions of the full RDF dump files into the SPARQL endpoint" \
                        'https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD-environment-variables' \
                        'unable to load the SPARQL endpoint with samples of the RDF that you created'

                     # TODO: is logging location set up correctly? Yes, but verify.

                  fi # end running as developer e.g. jsmith not loxd

                  if [[ -z "$i_am_project_user" ]]; then  # Running as developer e.g. jsmith not loxd
                     tomcat_installed="no"
                     if [[ -e '/etc/tomcat6/tomcat-users.xml' && \
                           -e '/etc/init.d/tomcat6'           && \
                           -d '/var/lib/tomcat6/webapps/' ]]; then
                        tomcat_installed="yes"
                     fi
                     if [[ "$tomcat_installed" == "yes" ]]; then
                        # The following two are also done above if virtuoso is installed.
                        # Calling them twice is safe.
                        echo
                        echo "$div `whoami`"
                        offer_install_aptget 'libapache2-mod-proxy-html' \
                                             "expose the (port 8080) Tomcat application server of SADI services at $our_base_uri/sadi-services"

                        echo "$div `whoami`"
                        enable_apache_module 'proxy_http' \
                                             "expose your (port 8080) Tomcat application server of SADI services at the URL $our_base_uri/sadi-services"
                        #                  ^ 'proxy' module is enabled when proxy_http is enabled.

                        # https://scm.escience.rpi.edu/trac/ticket/1502#comment:5 (sparql only)
                        # https://scm.escience.rpi.edu/trac/ticket/1612#comment:2 (sparql AND sadi-services)
                        #
                        # Mapping 5: works on datafaqstest and lofd (see virtuoso above for Mappings 1-4)
                        #
                        # ProxyPass /sadi-services http://localhost:8080/sadi-services
                        # ProxyPassReverse /sadi-services http://localhost:8080/sadi-services
                        # <Location /sadi-services>
                        #        Order allow,deny
                        #        allow from all
                        #        ProxyHTMLURLMap / /sparql/ c
                        #        ProxyHTMLURLMap http://localhost:8080/ /
                        #        SetOutputFilter proxy-html
                        # </Location>

                        echo # (This Apache-config modification pattern is repeated above for Virtuoso)
                        echo "$div `whoami`"
                        target='/etc/apache2/sites-available/default'
                        already_there=""
                        if [ -e $target ]; then
                           already_there=`grep 'Location /sadi-services' $target`
                        fi
                        echo "Some Apache directives (e.g., ProxyPass) need to be set in $target to expose your (port 8080) Tomcat application server at the URL $our_base_uri/sadi-services."
                        if [[ -z "$already_there" ]]; then
                           echo "To expose the (port 8080) Tomacat application server of SADI services at $our_base_uri/sadi-services,"
                           echo "the following apache configuration needs to be set in $target:"
                           echo                                                                          # Mapping 5 (see above)
                           echo '  ProxyTimeout 1800'                                                    > .prizms-apache-conf
                           echo '  ProxyRequests Off'                                                   >> .prizms-apache-conf
                           echo                                                                         >> .prizms-apache-conf
                           echo '  ProxyPass /sadi-services http://localhost:8080/sadi-services'        >> .prizms-apache-conf
                           echo '  ProxyPassReverse /sadi-services http://localhost:8080/sadi-services' >> .prizms-apache-conf
                           echo '  <Location /sadi-services>'                                           >> .prizms-apache-conf
                           echo '          Order allow,deny'                                            >> .prizms-apache-conf
                           echo '          allow from all'                                              >> .prizms-apache-conf
                           echo '          ProxyHTMLURLMap http://localhost:8080/ /'                    >> .prizms-apache-conf
                           echo '          SetOutputFilter proxy-html'                                  >> .prizms-apache-conf
                           echo '  </Location>'                                                         >> .prizms-apache-conf
                           cat .prizms-apache-conf

                           # Tuck the new directives into the entire configuration file.
                           virtualhost=`sudo  grep    "</VirtualHost>" $target`
                           sudo cat $target | grep -v "</VirtualHost>" > .apache-conf
                           cat .prizms-apache-conf                    >> .apache-conf
                           echo                                       >> .apache-conf
                           echo $virtualhost                          >> .apache-conf
                           echo
                           echo The final configuration file will look like:
                           echo
                           cat .apache-conf
                           read -p "Q: May we add the directives above to $target? [y/n] " -u 1 install_it
                           if [[ "$install_it" == [yY] ]]; then
                              sudo cp $target .$target_`date +%Y-%m-%d-%H-%M-%S`
                              #cat .prizms-apache-conf | sudo tee -a $target &> /dev/null
                              sudo mv .apache-conf $target
                              restart_apache
                           fi
                        else
                           echo "($target seems to already contain the ProxyPath directives to map /sadi-services to 8080)"
                        fi
                     fi
                  fi # end running as developer e.g. jsmith not loxd

                  if [[ -z "$i_am_project_user" ]]; then  # Running as developer e.g. jsmith not loxd

                     # TODO: X_GOOGLE_MAPS_API_Key
                     credentials="/etc/prizms/$project_user_name/??triple-store??/google/csv2rdf4lod-source-me-for-googlemap-credentials.sh"

                  fi # end "I am not project user"


                  if [[ -z "$i_am_project_user" ]]; then  # Running as developer e.g. jsmith not loxd

                     # AS both DEVELOPER and PROJECT USER (after dependencies were installed).
                     for user in $person_user_name $project_user_name; do

                        target="data/source/csv2rdf4lod-source-me-as-$user.sh"

                        # JENAROOT to data/source/csv2rdf4lod-source-me-as-$user.sh
                        echo
                        echo "$div `whoami`"
                        echo ${PRIZMS_HOME%/*}
                        find ${PRIZMS_HOME%/*} -type d -name "apache-jena*" # /home/lebot/opt/apache-jena-2.7.4
                        set_paths_cmd="export JENAROOT=`find ${PRIZMS_HOME%/*} -type d -name "apache-jena*" | tail -1 | sed "s/\`whoami\`/$user/g"`"
                        echo "Apache Jena requires the shell environent variable JENAROOT to be set."
                        echo "For details, see https://github.com/timrdf/csv2rdf4lod-automation/wiki/Apache-Jena"
                        echo "The following command should appear in $your data/source/csv2rdf4lod-source-me-as-$user.sh."
                        echo
                        echo "    $set_paths_cmd"
                        already_there=`grep "^$set_paths_cmd" $target`
                        echo
                        if [ -n "$already_there" ]; then
                           echo "It seems that you already have the following in $your $target, so we won't offer to add it again:"
                           echo
                           echo $already_there
                        else
                           read -p "Add this command to $your $target? [y/n] " -u 1 install_it
                           if [[ "$install_it" == [yY] ]]; then
                              echo $set_paths_cmd >> $target
                              echo
                              echo "Okay, we added it:"
                              grep "^$set_paths_command" $target
                              added="$added $target"
                           else
                              echo "We didn't change $your $target, so you'll need to make sure you set the paths correctly each time."
                           fi
                        fi
                     done
                  fi # end running as developer e.g. jsmith not loxd



                  # TODO: VSR_PROVENANCE='true' in source-me.sh

                  #
                  # DataFAQs services via mod_python
                  #
                  echo
                  echo "$div `whoami`"
                  offer_install_aptget \
                     'libapache2-mod-python' \
                     "expose DataFAQs services through Apache at $our_base_uri/services/sadi" # e.g. http://lofd.tw.rpi.edu/sadi-services/lift-ckan
                  if [[ $? != 0 ]]; then
                     enable_apache_module 'python' 'run DataFAQs SADI services'
                  fi

                  echo
                  echo "$div `whoami`"
                  www=`$PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/value-of.sh CSV2RDF4LOD_PUBLISH_VARWWW_ROOT data/source/csv2rdf4lod-source-me-as-$project_user_name.sh`
                  echo "Prizms deploys DataFAQs services by linking to them from within the htdocs directory, which is currently $www"
                  if [[ -d "$www" ]]; then
                     #pwd                       # /home/lebot/prizms/melagrid
                     #echo $PROJECT_PRIZMS_HOME # /home/melagrid/opt/prizms
                                                # /home/melagrid/opt/prizms/repos/DataFAQs/services
                     if [[ ! -e $www/services ]]; then
                        echo
                        echo "   sudo ln -s $PROJECT_PRIZMS_HOME/repos/DataFAQs/services $www/services"
                        echo
                        read -p "Q: May we link the DataFAQs services from your htdocs directory using the command above? [y/n] " -u 1 link_it
                        if [[ "$link_it" == [yY] ]]; then
                           echo sudo ln -s $PROJECT_PRIZMS_HOME/repos/DataFAQs/services $www/services
                                sudo ln -s $PROJECT_PRIZMS_HOME/repos/DataFAQs/services $www/services
                        else
                           echo "Okay, we won't link the DataFAQs services into your htdocs directory."
                        fi
                     fi
                  fi

                  if [[ -z "$i_am_project_user" ]]; then  # Running as developer e.g. jsmith not loxd
                     echo 
                     echo "$div `whoami`"
                     echo "Prizms pings datahub.io with lodcloud-specific metadata updates."
                     echo "datahub.io requires an API key."
                     credentials="/etc/prizms/$project_user_name/ckan/datahub.io/csv2rdf4lod-source-me-for-ckan-credentials.sh"
                     if [[ -e $credentials ]]; then
                        ckankey=`$PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/value-of.sh 'X_CKAN_API_Key' $credentials`
                     fi
                     if [[ -z "$ckankey" ]]; then
                        echo "$div `whoami`"
                        echo
                        echo "Prizms stores the datahub.io API Key that it uses outside of version control, so that it is kept from the public." 
                        echo
                        read -p "Q: May we set up $credentials to maintain the datahub.io API Key? [y/n] " -u 1 do_it
                        if [[ "$do_it" == [yY] ]]; then
                           echo
                           echo "Prizms uses X_CKAN_API_Key to authenticate to datahub.io."
                           echo
                           read -p "Q: What API Key should we use to update datahub.io metadata entries? " ckankey
                           echo
                           if [[ -n "$ckankey" ]]; then
                              change_source_me $credentials 'X_CKAN_API_Key' "$ckankey" \
                                 'authenticate to datahub.io' \
                                 'https://github.com/timrdf/DataFAQs/wiki/Missing-CKAN-API-Key' \
                                 'will not be able to inform datahub.io about this Prizms nodes'
                           fi
                        else
                           echo "Okay, we won't create $credentials. But we won't be able to use Virtuoso to load RDF data."
                           echo "See https://github.com/timrdf/DataFAQs/wiki/Missing-CKAN-API-Key"
                        fi
                     else
                        echo "(it appears that X_CKAN_API_Key is already set in $credentials)"
                     fi
                  fi # end running as developer e.g. jsmith not loxd


                  if [[ -z "$i_am_project_user" ]]; then  # Running as developer e.g. jsmith not loxd
                     for credentials in "/etc/prizms/$project_user_name/triple-store/virtuoso/csv2rdf4lod-source-me-for-virtuoso-credentials.sh" \
                                        "/etc/prizms/$project_user_name/ckan/datahub.io/csv2rdf4lod-source-me-for-ckan-credentials.sh"; do
                        if [[ -e $credentials ]]; then
                           target="data/source/csv2rdf4lod-source-me-credentials.sh"
                           echo
                           echo "$div `whoami`"
                           echo "$target is a public version controlled script that points to all credentials required for the project."
                           if [[ -e $target ]]; then
                              already_there=`grep $credentials $target`
                           else
                              already_there=""
                           fi
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
                     done
                  fi # end running as developer e.g. jsmith not loxd


                  # No need to avoid when $i_am_project_user, since the directory would already be created by the developer's invocation of the installer.
                  echo 
                  echo "$div `whoami`"
                  www=`$PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/value-of.sh CSV2RDF4LOD_PUBLISH_VARWWW_ROOT data/source/csv2rdf4lod-source-me-as-$project_user_name.sh`
                  echo "Prizms publishes RDF dump files into the htdocs directory, which is currently set to \"$www\"."
                  if [[ -n "$www" ]]; then
                     echo "$www/source should be owned by the project user $project_user_name."
                     if [[ ! -e $www/source ]]; then
                        echo
                        echo "$www/source does not exist, but can be made with the following command:"
                        echo
                        echo "   sudo mkdir -p $www/source"
                        echo
                        read -p "Q: May we create $www/source with the command above? [y/n] " -u 1 create_it
                        echo
                        if [[ "$create_it" == [yY] ]]; then
                           sudo mkdir -p $www/source
                        else
                           echo "Okay, we won't create $www/source, but you won't be able to publish RDF dump files or load the SPARQL endpoint."
                        fi
                     fi
                     if [[ -e $www/source                                         && \
                           `stat --format=%U $www/source` != "$project_user_name" && \
                           -n "$project_user_name" ]]; then
                        echo
                        echo "$www/source is currently owned by `stat --format=%U $www/source`, but it should be owned by $project_user_name."
                        echo "The correct ownership can be set using the following command."
                        echo
                        echo "   sudo chown -R $project_user_name:$project_user_name $www/source"
                        echo
                        read -p "Q: May we change ownership of $www/source with the command above? [y/n] " -u 1 create_it
                        echo
                        if [[ "$create_it" == [yY] ]]; then
                           sudo chown -R $project_user_name:$project_user_name $www/source
                        else
                           echo "Okay, we won't change the owner of $www/source, but you won't be able to publish RDF dump files or load the SPARQL endpoint."
                        fi
                     fi
                  else
                     echo
                     echo "WARNING: could not find value of CSV2RDF4LOD_PUBLISH_VARWWW_ROOT (found $www) in `pwd`/data/source/csv2rdf4lod-source-me-as-$project_user_name.sh"
                     if [[ ! -e data/source/csv2rdf4lod-source-me-as-$project_user_name.sh ]]; then
                        echo "Perhaps there is an issue pushing your changes to $project_code_repository ?"
                     fi
                     echo
                     read -p "Press any key to continue." -u 1
                  fi

                  if [[ -z "$i_am_project_user" ]]; then # Running as developer e.g. jsmith not loxd

                     # Apache module 'env' is needed to enable the SetEnv command in the 
                     # $PROJECT_PRIZMS_HOME/repos/DataFAQs/services/.htaccess below.
                     enable_apache_module 'env' 'enable DataFAQs provenance'

                     # AllowOverride None -> AllowOverride All
                     enable_htaccess "DataFAQs needs to access environment variables set in .htaccess files to assert its provenance and POST to CKAN."

                     # tail -f /var/log/apache2/error.log
                  else
                     echo
                     echo "$div `whoami`"
                     echo "Prizms exposes a directory of python SADI services through Apache, which needs to know what implementation should handle the invocation."
                     target="$PROJECT_PRIZMS_HOME/repos/DataFAQs/services/.htaccess"
                     if [[ ! -e $target ]]; then
                        echo "$target does not exist, but it should contain the following directives to enable the SADI services:"
                        echo
                        echo "Options -MultiViews"                     > .prizms-sadi-htaccess
                        echo "SetHandler mod_python"                  >> .prizms-sadi-htaccess
                        echo "PythonHandler sadi"                     >> .prizms-sadi-htaccess
                        # SetEnv X_CKAN_API_Key     # This needs 'sudo a2enmod env' to take affect. # see http://httpd.apache.org/docs/2.2/mod/mod_env.html
                        echo "SetEnv DATAFAQS_BASE_URI $our_base_uri" >> .prizms-sadi-htaccess
                        cat .prizms-sadi-htaccess
                        echo
                        read -p "Q: May we install the directives above into $target? [y/n] " -u 1 install_it
                        if [[ "$install_it" == [yY] ]]; then
                           mv .prizms-sadi-htaccess $target
                        else
                           echo "Okay, we won't update $target."
                        fi
                        # TODO: set envvars in /etc/apache2/envvars as:
                        # export X_CKAN_API_Key=aabbcc
                     else
                        echo "($PROJECT_PRIZMS_HOME/repos/DataFAQs/services/.htaccess already exists, so mod_python should be configured to use sadi handler)"
                     fi
                     rm -f .prizms-sadi-htaccess
                  fi
     
    
                  echo
                  echo "$div `whoami`"
                  target='/etc/apache2/envvars'
                  already_there=`grep X_CKAN_API_Key $target`
                  echo "Prizms uses some SADI services that write to the CKAN at http://datahub.io, which requires an API key."
                  echo "Since the SADI services access the X_CKAN_API_Key environment variable and are invoked through Apache,"
                  echo "the Apache environment variable X_CKAN_API_Key needs to be set in $target."
                  if [[ -z "$already_there" ]]; then
                     echo "set X_CKAN_API_Key in $target."
                     read -p "Do nothing? (needs to be implemented)^^ todo... [y/n] " -u 1 add_it
                  else
                     echo "(X_CKAN_API_Key is already set in $target)"
                  fi




                  if [[ -z "$i_am_project_user" ]]; then # Running as developer e.g. jsmith not loxd
                     #
                     # LODSPeaKr: https://github.com/alangrafu/lodspeakr/wiki/How-to-install-requisites-in-Ubuntu
                     #
                     echo
                     echo "$div `whoami`"
                     www=`$PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/util/value-of.sh CSV2RDF4LOD_PUBLISH_VARWWW_ROOT data/source/csv2rdf4lod-source-me-as-$project_user_name.sh`
                     echo "Prizms uses LODSPeaKr to serve its RDF as Linked Data, and to serve the corresponding human-web pages."
                     echo
                     echo "LODSPeaKr lives within the htdocs directory ($www),"
                     echo "while your $project_user_name Prizms will maintain the model/views within"
                     echo "the version-controlled repository ($project_code_repository)." 
                     echo
                     if [[ ! -e $www/lodspeakr ]]; then
                        lodchown=www-data:$project_user_name # A) user 'www-data' so apache can write; B) a group where www-data can write
                        echo "$www/lodspeakr is not set up yet. It can be installed with the command:"
                        echo
                        echo " sudo bash -s base-url=$our_base_uri base-namespace=$our_base_uri sparql-endpoint=$our_base_uri/sparql chown=$lodchown < <(curl -sL http://lodspeakr.org/install)"
                        echo
                        read -p "Q: Would you like to install LODSPeaKr? [y/n] " -u 1 install_it
                        if [[ "$install_it" == [yY] ]]; then
                           offer_install_aptget "curl apache2 php5 php5-cli php5-sqlite php5-curl sqlite3" 'run LODSPeaKr'
                           pushd $www &> /dev/null
                              # bash -s http://server/baseurl http://example.org/namespace/ http://server/sparql  < <(curl -sL http://lodspeakr.org/install)
                              # see https://github.com/alangrafu/lodspeakr/wiki/Installation#wiki-automatic
                              #sudo bash < <(curl -sL http://lodspeakr.org/install)
                              sudo bash -s base-url=$our_base_uri -s base-namespace=$our_base_uri -s sparql-endpoint=$our_base_uri/sparql -s chown=$lodchown < <(curl -sL http://lodspeakr.org/install)
                              # Question 1: http://lod.melagrid.org
                              # Question 2: <accept default>
                              # Question 3: http://lod.melagrid.org/sparql
                           popd &>/dev/null
                        else
                           echo "Okay, we won't install LODSPeaKr at $www/lodspeakr."
                        fi
                     fi
                  fi

                  if [[ -z "$i_am_project_user" ]]; then # Running as developer e.g. jsmith not loxd
         
                     if [[ -e $www/lodspeakr ]]; then
                        offer_install_aptget "curl apache2 php5 php5-cli php5-sqlite php5-curl sqlite3" 'run LODSPeaKr'

                        enable_apache_module 'rewrite' 'run LODSPeaKr'
                        enable_apache_module 'php5'    'run LODSPeaKr'

                        # AllowOverride must be 'All' https://github.com/alangrafu/lodspeakr/wiki/How-to-install-requisites-in-Ubuntu
                        enable_htaccess "LODSPeaKr needs .htaccess"
                     fi
                     if [[ -e $www/lodspeakr && ! -e $www/lodspeakr/settings.inc.php ]]; then
                        echo
                        echo "$www/lodspeakr was created, but not configured with settings.inc.php"
                        echo
                        read -p "Q: Would you like to configure LODSPeaKr now? [y/n] " -u 1 install_it
                        if [[ "$install_it" == [yY] ]]; then
                           pushd $www/lodspeakr &> /dev/null
                              sudo ./install.sh base-url=$our_base_uri base-namespace=$our_base_uri sparql-endpoint=$our_base_uri/sparql chown=$lodchown
                           popd &> /dev/null
                        else
                           echo "Okay, we won't configure LODSPeaKr at $www/lodspeakr."
                        fi
                     fi
                     if [[ -e $www/lodspeakr/settings.inc.php ]]; then
                        sudo chown $project_user_name:www-data $www/lodspeakr/settings.inc.php
                        sudo chmod g+w                         $www/lodspeakr/settings.inc.php

                        # /var/www$ sudo chmod -R g+w lodspeakr/cache lodspeakr/meta lodspeakr/settings.inc.php; sudo chgrp -R www-data lodspeakr/cache lodspeakr/meta lodspeakr/settings.inc.php
            
                        # If /var/www/lodspeakr/settings.inc.php exists and is not a soft link to /home/ieeevis/prizms/ieeevis/lodspeakr/settings.inc.php,
                        # move it into the developer's working copy, soft link into the project user's read-only clone.
                        target="$www/lodspeakr/settings.inc.php"
                        if [[ ! -h $target ]]; then
                           echo
                           echo "$div `whoami`"
                           echo "$target exists, but is not soft-linked into $project_user_name's read-only clone of $project_code_repository."
                           echo "The following commands will place settings.inc.php into your development clone, and link to $project_user_name's read-only production clone."
                           echo
                           echo    sudo mv $target $user_home/prizms/$project_user_name/lodspeakr/settings.inc.php
                           echo    sudo ln -s      $project_user_home/prizms/$project_user_name/lodspeakr/settings.inc.php $target
                           echo
                           read -p "Q: Peform the commands above to put settings.inc.php under version controll? [y/n] " -u 1 install_it
                           if [[ "$install_it" == [yY] ]]; then
                              sudo mv $target $user_home/prizms/$project_user_name/lodspeakr/settings.inc.php
                              sudo ln -s      $project_user_home/prizms/$project_user_name/lodspeakr/settings.inc.php $target
                              added="$added lodspeakr/settings.inc.php"
                              # Move the file and make the soft link.
                           else
                              echo "Okay, we will leave $www/lodspeakr/settings.inc.php as not version controlled."
                           fi
                        fi
                     fi # -e $www/lodspeakr/settings.inc.php
                  fi

                  if [[ -z "$i_am_project_user" ]]; then # Running as developer e.g. jsmith not loxd

                     # TODO: change $lodspk['title'] = 'LODSPeaKr'; in settings.inc.php

                     # TODO: https://github.com/timrdf/provenanceweb/wiki/Installation#enable-visualbox

                     # The following need to be updated if --our-base-uri becomes e.g. http://ieeevis.tw.rpi.edu
                     # $conf['endpoint']['local'] = 'http://aquarius.tw.rpi.edu/projects/ieeevis/sparql';
                     # $conf['basedir'] = 'http://aquarius.tw.rpi.edu/projects/ieeevis/';
                     # $conf['ns']['local']   = 'http://aquarius.tw.rpi.edu/projects/ieeevis/';



                     # LODSPeaKr logo
                     echo
                     echo "$div `whoami`"
                     echo "LODSPeaKr permits a logo for the web site."
                     echo "The logo should be placed at /home/$person_user_name/prizms/$project_user_name/lodspeakr/components/static/img/logo.png"
                     echo
                     if [[ ! -e /home/$person_user_name/prizms/$project_user_name/lodspeakr/components/static/img/logo.png ]]; then
                        read -p "Q: Did you know that you can add a logo to your site? [y/n] " -u 1 logo
                     else
                        echo "(/home/$person_user_name/prizms/$project_user_name/lodspeakr/components/static/img/logo.png already exists)"
                     fi


                     # Avoid index.html
                     echo
                     echo "$div `whoami`"
                     echo "Prizms does not need the index.html in the htdocs directory, since it uses lodspeakr"
                     if [[ -e $www/index.html ]]; then
                        echo
                        echo "mv $www/index.html $www/it.works"
                        echo
                        read -p "Q: May we move the default index.html out of LODSPeaKr's way using the command above? [y/n] " -u 1 move_it
                        if [[ "$move_it" == [yY] ]]; then
                           sudo mv $www/index.html $www/it.works
                        else
                           echo "Okay, we won't move it. But the site will not work."
                        fi
                     else
                        echo "(the $www/index.html is not there, so it's not in lodspeakr's way.)"
                     fi


                     echo
                     echo "$div `whoami`"
                     echo "Prizms maintains the LODSPeaKr components under version control ($project_code_repository)"
                     echo "See https://github.com/alangrafu/lodspeakr/wiki/Develop-your-own-components-in-a-different-repository"
                     if [[ ! -h $www/lodspeakr/components ]]; then # Is not an alias. # TODO: and it points to within our github clone...
                        if [[ -d $www/lodspeakr/components && ! -e lodspeakr/components ]]; then
                           echo
                           echo "We need to put lodspeakr into version control, which can be done with the following commands."
                           echo
                           echo "   sudo mv $www/lodspeakr/components `pwd`/lodspeakr/"
                           echo "   sudo chown -R `stat --format=%U:%G ~/` `pwd`/lodspeakr/components"
                           echo "   sudo ln -s `pwd | sed "s/\`whoami\`/$project_user_name/"`/lodspeakr/components $www/lodspeakr/components"
                           echo
                           read -p "Q: May we move $www/lodspeakr/components to `pwd`/lodspeakr/components using the commands above? [y/n] " -u 1 move_it
                           if [[ "$move_it" == [yY] ]]; then
                              
                              sudo mv $www/lodspeakr/components `pwd`/lodspeakr/
                              added="$added lodspeakr/components"
                              sudo chown -R `stat --format=%U:%G ~/` `pwd`/lodspeakr/components
                              sudo ln -s `pwd | sed "s/\`whoami\`/$project_user_name/"`/lodspeakr/components $www/lodspeakr/components
                           else
                              echo "Okay, we won't include lodspeakr/components into version control."
                           fi 
                        elif [[ ! -e $www/lodspeakr/components && -d lodspeakr/components ]]; then
                           echo
                           echo "We link $www/lodspeakr/components to the version-controlled directory `pwd | sed "s/\`whoami\`/$project_user_name/"`/lodspeakr/components"
                           echo
                           echo "   sudo ln -s `pwd | sed "s/\`whoami\`/$project_user_name/"`/lodspeakr/components $www/lodspeakr/components"
                           echo
                           read -p "Q: May we move $www/lodspeakr/components to `pwd`/lodspeakr/components using the commands above? [y/n] " -u 1 move_it
                           if [[ "$move_it" == [yY] ]]; then
                              sudo ln -s `pwd | sed "s/\`whoami\`/$project_user_name/"`/lodspeakr/components $www/lodspeakr/components
                           else
                              echo "Okay, we won't include lodspeakr/components into version control."
                           fi 
                        else
                           echo "Whah?! not sure why $www/lodspeakr/components is not an alias, and lodspeakr/components already exists."
                        fi
                     else
                        echo "(LODSPeaKr is already under version control)" 
                     fi


 
                     # Multiple users development site (https://github.com/timrdf/prizms/issues/16)
                     echo
                     echo "$div `whoami`"
                     echo "Prizms permits development of its LODSPeaKr within developers' namespaces (e.g. $our_base_uri/~$person_user_name)."
                     echo "This allows developers to prototype data views before committing them to the production site (e.g. $our_base_uri)."
                     echo "Once finished, developers commit their code to $project_code_repository and the $project_user_name user pulls it to deploy at $our_base_uri."
                     echo
                     enable_apache_module 'userdir' "run development clones of the $project_user_name Prizm's LODSPeaKr"  

                     if [[ ! -e /etc/apache2/mods-enabled/php5.conf ]]; then
                        read -p "WARNING: /etc/apache2/mods-enabled/php5.conf does not exist, so we're not sure how to enable user-level php. (press enter to continue) " -u 1 oops
                        #if [[ "$make_it" == [yY] ]]; then
                        #   mkdir $user_home/public_html
                        #else
                        #   echo "Okay, we won't include lodspeakr/components into version control."
                        #fi 
                     else
                        if [[ ! `grep ".*#.*<IfModule *mod_userdir.c" /etc/apache2/mods-enabled/php5.conf` ]]; then
                           echo
                           echo "The following directive in /etc/apache2/mods-enabled/php5.conf needs to be **commented out** to enable user-level php."
                           echo
                           echo "    <IfModule mod_userdir.c>"
                           echo "        <Directory /home/*/public_html>"
                           echo "            php_admin_value engine Off"
                           echo "        </Directory>"
                           echo "    </IfModule>"

                           read -p "Q: Can you please go comment it out, and press 'y' when finished? [y/n] " -u 1 commented_out
                           if [[ "$commented_out" == [yY] ]]; then
                              if [[ ! `grep ".*#.*<IfModule *mod_userdir.c" /etc/apache2/mods-enabled/php5.conf` ]]; then
                                 echo "It doesn't look like you commented it out. Try again by running the installer again."
                                 read -p "Q: Can you please go comment it out, and press 'y' when finished? [y/n] " -u 1 commented_out
                              fi
                           else
                              echo "Okay, but user-level php for your Prizms LODSPeakr will not be enabled."
                           fi 
                        fi
                     fi

                     echo
                     echo "$div `whoami`"
                     echo "Your Prizms LODSPeaKr development clone should exist within $user_home/public_html"
                     if [[ ! -e $user_home/public_html ]]; then
                        echo
                        read -p "Q: Make directory $user_home/public_html ? [y/n] " -u 1 make_it
                        if [[ "$make_it" == [yY] ]]; then
                           mkdir $user_home/public_html
                        else
                           echo "Okay, we won't include lodspeakr/components into version control."
                        fi 
                     else
                        echo "($user_home/public_html exists)"
                     fi
                     if [[ -e $user_home/public_html && ! -e $user_home/public_html/lodspeakr ]]; then
                        # mkdir  ~/public_html; echo "hi" > ~/public_html/hi.txt
                        # http://lofd.tw.rpi.edu/~lebot/hi.txt
                        pushd $user_home/public_html &> /dev/null
                           comps=$user_home/prizms/$project_user_name/lodspeakr/components
                           base=$our_base_uri/~$person_user_name/
                           perms="-s chown=www-data chmod=774"
                           perms="-s chmod=777" # https://github.com/timrdf/prizms/issues/18 TODO
                           echo
                           echo bash -s components=$comps -s base-url=$base -s base-namespace=$our_base_uri -s sparql-endpoint=$our_base_uri/sparql $perms < <(curl -sL http://lodspeakr.org/install)
                           echo
                           read -p "Q: Install your Prizms LODSPeaKr development clone with the command above? [y/n] " -u 1 install_it
                           if [[ "$install_it" == [yY] ]]; then
                              bash -s components=$comps base-url=$base base-namespace=$our_base_uri sparql-endpoint=$our_base_uri/sparql $perms < <(curl -sL http://lodspeakr.org/install)
                              #sudo chown -R `stat --format=%U:%G ~/` $user_home/public_html/lodspeakr
                           else
                              echo "Okay, we didn't install it."
                           fi 
                        popd &> /dev/null
                     fi
                   
                     # TODO: $user_home/public_html/lodspeakr/settings.inc.php should contain the following
                     #
                     # $conf['home'] = '/home/lebot/public_html/lodspeakr/'; // $conf['home'] = '/var/www/lodspeakr/';
                     # $conf['basedir'] = 'http://lofd.tw.rpi.edu/~lebot/';
                     # $conf['debug'] = false;
                     #
                     # $conf['ns']['local']   = 'http://lofd.tw.rpi.edu/';
                     # $conf['mirror_external_uris'] = true;
 
                  fi # Running as developer e.g. jsmith not loxd


                  # Link in existing upstream projects' LODSPeaKrs (https://github.com/timrdf/prizms/issues/12)
                  # per https://github.com/alangrafu/lodspeakr/wiki/Reuse-cherry-picked-components-from-other-repositories
                  #
                  # Note that this requires the production user to be set up already. (TODO: or does it? Can't the production user just do it?)
                  if [[ -n "$i_am_project_user" && -e $www/lodspeakr/settings.inc.php ]]; then  # Running as production user e.g. loxd not jsmith # TODO: try to do as production user.
                            target='/var/www/lodspeakr/settings.inc.php'
                     target_backup="/var/www/lodspeakr/.settings.inc.php_`date +%Y-%m-%d-%H-%M-%S`"
                     sudo="sudo" # TODO: try to do as production user.
                     if [[ -h $target ]]; then # FILE exists and is a symbolic link.
                               target='lodspeakr/settings.inc.php'
                        target_backup="lodspeakr/.settings.inc.php_`date +%Y-%m-%d-%H-%M-%S`"
                        sudo="" # TODO: try to do as production user.
                     fi
                     $sudo cp $target $target_backup
                     echo
                     echo "$div `whoami`"
                     echo "Prizms can use existing upstream LODSPeaKrs by referencing them within settings.inc.php."
                     echo "($target) `whoami` at `pwd`"
                     echo
                     for upstream in `find $project_user_home/opt/prizms/lodspeakrs -mindepth 2 -maxdepth 2 -type d -name lodspeakr`; do
                        for ctype in services types; do
                           for component in `find $upstream/components/$ctype -mindepth 1 -maxdepth 1`; do
                              # ^ e.g. /home/lofd/opt/prizms/lodspeakrs/twc-healthdata/lodspeakr/components/services/namedGraphs

                              there=`grep "$conf.'components'..'$ctype'... = '$component';" $target`

                              cherry_pick="\$conf['components']['$ctype'][] = '$component';"
                              if [[ $there ]]; then
                                 disabled=`echo $there | grep "^#"`; disabled=${#disabled}
                                 #if [[ ! $disabled ]]; then
                                 #   echo "^ there, not disabled (need to check the primary `$project_user_home/prizms/$project_user_name/lodspeakr/components/$ctype`"
                                 #fi
                              else
                                 echo "^ not there; add $cherry_pick"
                                 # =>
                                 # $conf['components']['types'][] = '/home/alvaro/previousproject1/lodspeakr/components/types/foaf:Person';
                                 # $conf['components']['services'][] = '/home/lofd/opt/prizms/lodspeakrs/twc-healthdata/lodspeakr/components/services/namedGraphs';
                                 read -p "Q: Add $component as an external LODSPeaKr component? [y/n] " -u 1 enable
                                 if [[ $enable == [nN] ]]; then
                                    cherry_pick="// $cherry_pick"
                                 fi
                                 if [[ ${#enable} -gt 0 ]]; then
                                    cat $target | awk -v add="$cherry_pick" '{if($0 ~ /^...Cherry-picked components/){print;print add}else{print}}' > .prizms-installer-settings.inc.php
                                    $sudo mv .prizms-installer-settings.inc.php $target # TODO: try to do as production user.
                                    if [[ -h $target ]]; then
                                       added="$added lodspeakr/settings.inc.php"
                                    fi
                                 fi
                              fi
                              #echo
                           done
                        done
                     done
                  fi # Running as production user e.g. loxd not smithj

                  # robots.txt
                  echo
                  echo "$div `whoami`"
                  echo "Prizms nodes are more useful when automated agents are permitted to crawl and index the data on its site."
                  echo "$our_base_uri/robots.txt needs to permit web agents to crawl the site, which can be done by renaming the file with:"
                  echo
                  echo "   mv $www/robots.txt $www/permit.robots.txt"
                  echo
                  if [[ -e $www/robots.txt && `grep 'Disallow: /' $www/robots.txt` ]]; then
                     read -p "Q: May we permit automated agents by renaming the file with the command above? [y/n] " -u 1 rename_it
                     if [[ "$rename_it" == [yY] ]]; then
                        sudo mv $www/robots.txt $www/permit.robots.txt
                        sudo touch $www/robots.txt
                        if [[ ! -e $www/robots.txt ]]; then
                           echo "($www/robots.txt renamed)"
                        else
                           echo "(WARNING: could not rename $www/robots.txt)"
                        fi
                     else
                        echo "We didn't change $www/robots.txt"
                     fi 
                  else
                     echo "($www/robots.txt appears to permit automated agents)"
                  fi

                  # $www/robots.txt
                  # Sitemap: http://ieeevis.tw.rpi.edu/source/ieeevis-tw-rpi-edu/file/cr-sitemap/version/latest/conversion/sitemap.xml
                  # Sitemap: $our_base_uri/source/$our_source_id/file/cr-sitemap/version/latest/conversion/sitemap.xml
                  echo
                  echo "$div `whoami`"
                  echo "Automated web agents can use the 'Sitemap:' directive of $our_base_uri/robots.txt"
                  echo "to keep the data in Prizms in sync with their indexing. The robots.txt directive is:"
                  echo
                  echo "Sitemap: $our_base_uri/source/$our_source_id/file/cr-sitemap/version/latest/conversion/sitemap.xml"
                  echo
                  if [[ ! -e $www/robots.txt || \
                          -e $www/robots.txt && ! `grep "^Sitemap: $our_base_uri/source/$our_source_id/file/cr-sitemap/version/latest/conversion/sitemap.xml$" $www/robots.txt` ]]; then
                     read -p "Q: Add the Sitemap directive to $www/robots.txt? [y/n] " -u 1 add_it
                     if [[ "$add_it" == [yY] ]]; then
                        echo "Sitemap: $our_base_uri/source/$our_source_id/file/cr-sitemap/version/latest/conversion/sitemap.xml" | sudo tee $www/robots.txt
                     else
                        echo "We didn't change $www/robots.txt"
                     fi
                  else
                     echo "($www/robots.txt seems to contain the right Sitemap directive.)"
                  fi

                  #
                  # Sprinkle "access.ttl" files within the csv2rdf4lod conversion root, as mirrors of the upstream CKAN.
                  #
                  # http://data.melagrid.org/cowabunga/dude.html -> data-melagrid-org
                  echo
                  echo "$div `whoami`"
                  export CLASSPATH=$CLASSPATH`$PRIZMS_HOME/bin/install/classpaths.sh` 
                  upstream_ckan_source_id=`java edu.rpi.tw.string.NameFactory --source-id-of $upstream_ckan`
                  target="data/source/$upstream_ckan_source_id"
                  echo "Prizms can collect and convert datasets that are listed in CKAN instances."
                  if [[ -n "$upstream_ckan" && "$upstream_ckan" != "none" ]]; then
                     echo "You've specified an upstream CKAN from which to mirror dataset listings ($upstream_ckan),"
                     echo "but Prizms hasn't extracted the access metadata into $target."
                     if [[ -n "$upstream_ckan_source_id" && -z "$i_am_project_user" ]]; then # Running as developer e.g. jsmith not loxd
                        echo
                        read -p "Q: May we extract the access metadata from the datasets in $upstream_ckan, placing them within $target? [y/n] " -u 1 extract_it
                        if [[ "$extract_it" == [yY] ]]; then
                           mkdir -p $target
                           pushd $target &> /dev/null
                              echo cr-create-dataset-dirs-from-ckan.py $upstream_ckan/api $our_base_uri
                                   cr-create-dataset-dirs-from-ckan.py $upstream_ckan/api $our_base_uri
                              for access in `find . -name access.ttl`; do
                                 added="$added $target/${access#./}"
                              done
                           popd &> /dev/null
                        else
                           echo "Okay, we won't try to extract access metadata from $upstream_ckan. Check out the following if you want to do it yourself:"
                           echo "  https://github.com/jimmccusker/twc-healthdata/wiki/Mirroring-a-Source-CKAN-Instance"
                        fi
                     fi
                  else
                     echo "(You are not using an upstream CKAN; call this installer with argument --upstream-ckan if you want to)"
                  fi




                  echo
                  echo "$div `whoami`"
                  target="data/source/$our_source_id/cr-cron/version/cr-cron.sh"
                  echo "Prizms automates dataset updates by regularly invoking $target with cron."
                  echo "$target is maintained using version control,"
                  echo "and is retrieved by the cronjob itself to determine additional tasks that it should perform."
                  echo "The cronjob is run by the user $project_user_name."
                  echo "See https://github.com/jimmccusker/twc-healthdata/wiki/Automation"
                  if [[ -z "$i_am_project_user" ]]; then  # Running as developer e.g. jsmith not loxd
                     # Set up cronjob as cr-cron.sh
                     template="$PRIZMS_HOME/repos/csv2rdf4lod-automation/bin/cr-cron.sh"
                     if [[ -n "$our_source_id" ]]; then
                        if [[ ! -e $target ]]; then
                           echo
                           read -p "There isn't a $target in your repository, should we add it for you? [y/n] " -u 1 install_it
                           echo
                           if [[ "$install_it" == [yY] ]]; then
                              mkdir -p `dirname $target`
                              cp $template $target
                              chmod +x $target
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
                     # Setting up the crontab is done as the project's production user 
                     # (called recursively at the end of this script) -- NOT on the developer user name.
                  else
                     # Set up crontab for the cronjob cr-cron.sh
                     target="`pwd`/data/source/$our_source_id/cr-cron/version/cr-cron.sh"
                     if [[ -n "$our_source_id" && -e $target ]]; then
                        tab=.prizms.`basename $0`.crontab
                        crontab -l 2> /dev/null > $tab
                        already_there=`grep $target $tab`
                        if [[ -z "$already_there" ]]; then
                           echo
                           echo "There is a cronjob available at $target, but it is not included in your crontab."
                           echo
                           echo "Your crontab is currently:"
                           cat $tab
                           echo
                           m=$(($RANDOM%60))
                           h=$(($RANDOM%24))
                           # m h  dom mon dow   command
                           # 14 20 * * * /srv/twc-healthdata/data/source/healthdata-tw-rpi-edu/cr-cron/version/cron.sh
                           echo "# m h  dom mon dow   command" >> $tab
                           echo "$m $h * * * $target"          >> $tab
                           echo ""                             >> $tab
                           echo "We would like to update your crontab so that it is:"
                           echo
                           cat $tab
                           read -p "Q: Add to crontab? [y/n] " -u 1 install_it
                           if [[ $install_it == [yY] ]]; then
                              crontab $tab
                              echo "Crontab now set to:"
                              crontab -l 2> /dev/null
                           fi
                        else
                           echo "(`whoami`'s crontab already contains a call to $target)"
                        fi
                        rm $tab
                     else
                        echo "Cannot set up crontab because cronjob $target is not available."
                     fi
                  fi # end "I am not project user"


                  # TODO: add warning if more than one "cr-cron.sh" in crontab




                  # Finished.

                  #
                  # Add all new files to version control.
                  #
                  if [ -n "$added" ]; then # This should never pass when $i_am_project_user, if it does, something above shouldn't changed $added.
                     echo
                     echo "$div `whoami`"
                     echo "We just added the following to `pwd`"
                     echo "   $added"
                     echo
                     read -p "Q: ^--- Since we modified these files to your working copy of $project_code_repository, let's add, commit, and push them, okay? [y/n] " -u 1 push_them
                     if [[ "$push_them" == [yY] ]]; then
                        git add -f $added
                        git commit -m 'During Prizms install: added stub directories and readme files.'
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


                  if [[ -z $i_am_project_user ]]; then # Running as developer e.g. jsmith not loxd
                     # ^ We are currently doing this \/ (avoid the infinite loop)
                     #echo
                     #echo "$div `whoami`"
                     #echo "Since we've made some changes to apache, we need to restart it so they take effect."
                     #echo
                     #echo sudo service apache2 restart
                     #echo
                     #read -p "Q: May we restart apache using the command above? [y/n] " -u 1 restart_it
                     #if [[ "$restart_it" == [yY] ]]; then
                     #   sudo service apache2 restart
                     #fi

                     echo
                     echo "$div `whoami`"
                     echo "We've finished setting up your development environment."
                     echo "The next step is to set up the $project_user_name's production environment,"
                     echo "which we can do by running this script again as user $project_user_name"
                     echo
                     read -p "Q: Set up the production environment as the $project_user_name user? [y/n] " -u 1 as_project
                     if [[ "$as_project" == [yY] ]]; then
                        read_only_project_code_repository=`echo $project_code_repository | sed 's/git@github.com:/git:\/\/github.com\//'`
                        # ^ e.g. git@github.com:jimmccusker/melagrid.git -> git://github.com/jimmccusker/melagrid.git

                        # Bootstrap the project user with this install script.
                        echo
                        echo ${user_home%/*}/$project_user_name/opt/prizms
                        echo
                        if [[ ! -e ${user_home%/*}/$project_user_name/opt/prizms ]]; then
                           echo sudo su - $project_user_name -c "cd; mkdir -p opt; cd opt; git clone git://github.com/timrdf/prizms.git"
                                sudo su - $project_user_name -c "cd; mkdir -p opt; cd opt; git clone git://github.com/timrdf/prizms.git"
                        else
                           echo sudo su - $project_user_name -c "cd opt/prizms; git pull"
                                sudo su - $project_user_name -c "cd opt/prizms; git pull"
                        fi

                        sudo su - $project_user_name -c "cd; opt/prizms/bin/install.sh                                \
                                                                  --me                                                \
                                                                  --my-email                                          \
                                                                  --proj-user      $project_user_name                 \
                                                                  --repos          $read_only_project_code_repository \
                                                                  --upstream-ckan  $upstream_ckan                     \
                                                                  --our-base-uri   $our_base_uri                      \
                                                                  --our-source-id  $our_source_id                     \
                                                                  --our-datahub-id $our_datahub_id"
                     else
                        echo "Okay, we won't set up the production environment."
                     fi
                  fi

                  # Do any setup that the developer needs to do after the production user was setup.



                  echo
                  echo "$div `whoami`"
                  if [[ -n $i_am_project_user ]]; then
                     echo "We're all done installing Prizms production environment for the user `whoami`."
                  else # Running as developer e.g. jsmith not loxd
                     echo "We're all done installing Prizms development environment for the user `whoami`."
                     echo
                     echo "$div `whoami`"
                     echo "Now what?"
                     echo "* Check out the data site $our_base_uri/"
                     echo "* Check out the SPARQL endpoint $our_base_uri/sparql"
                     echo "* Start committing DCAT and eparams into github repository $project_code_repository"
                  fi

                  # TODO: Add descriptions of the github and ckan I to what the prizms offers as linked data. 
                  # Use that same kind of file as the parameter to the install. 
                  # Organize it into a versioned dataset (just like everything else).

               popd &> /dev/null
            fi # if $target_dir e.g. /home/lebot/prizms/melagrid
         popd &> /dev/null
      else
         echo "If you aren't going to use a code repository, we can't help you very much."
      fi
   popd &> /dev/null
fi
