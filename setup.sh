#!/bin/bash

OPENSRC_DIR=/QOpenSys/pkgs/bin

################################################################################
#
#                               Procedures.
#
################################################################################

#       exist_directory dest
#
#       dest is an directory to check
#
#       exit 1 (succeeds) directort exist, else 0.

exist_directory()

{	
        [ -d "${1}" ] && return 0  || return 1      

}

#
#       install_yum_dependencies
#


install_yum_dependencies()

{	
        yum -y install 'make-gnu' 'curl' 'jq'     
}

#
#       install_other_dependencies
#


install_other_dependencies()

{	
        curl https://api.github.com/repos/jsranko/si-iws-builder/releases/latest --insecure | jq '.assets[].browser_download_url | select(contains("with-"))' | xargs -n1 curl --output si-iws-builder-latest.jar --insecure --location

}


################################################################################
#
#                               Main
#
################################################################################

if exist_directory "${OPENSRC_DIR}";  then
    echo "5733-OPS product is installed ..."
else 
    echo "Please install 5733-OPS product first."
fi

# set path to OpenSource
echo "setting path to OpenSource ..."
export PATH=${OPENSRC_DIR}:$PATH

echo "installing dependencies for si-iws-builder-example ..."
echo "installing yum dependencies ..."
install_yum_dependencies

echo "installing other dependencies ..."
install_other_dependencies
