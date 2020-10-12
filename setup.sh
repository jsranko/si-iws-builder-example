#!/bin/bash

JAR_FILE=si-iws-builder-latest.jar
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
#       install_jar_dependencies
#


install_jar_dependencies()

{		
		if [ -f "$1" ]; then		
			echo "All Jar dependencies are present."  
		else
    		echo "$1 does not exist. It will be downloaded ..."    		    		
			curl http://files.sranko-informatik.de/getGithubPackage.php?package=si-iws-builder --output $1
		fi

        

}

#
#       build_project
#


build_project()

{	
        gmake all

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

echo "installing jar dependencies ..."
install_jar_dependencies ${JAR_FILE}

echo "build si-iws-builder-example ..."
build_project

