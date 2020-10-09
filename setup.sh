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
			curl -H "Authorization: bearer ee08d76790ed01459f29e8824ed37a4025f44e23" -X POST -d '{"query":"query { 
    		  repository(owner:"jsranko", name:"si-iws-builder") {
    		packages (last:1) {
    		            nodes {
    		                versions(last:1) {
    		                    nodes {
    		                        files(first:3, orderBy: {field: CREATED_AT, direction: DESC}){
    		                            nodes {
    		                                name 
    		                                url
    		                              }  
    		                            }
    		                     }    
    		                }
    		            }
    		        }
    		    }      
}
"}' https://api.github.com/graphql --insecure
#			curl https://api.github.com/repos/jsranko/si-iws-builder/releases/latest --insecure | jq '.assets[].browser_download_url | select(contains("with-"))' | xargs -n1 curl --output $1 --insecure --location
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

data=$(curl -H "Authorization: token $GITHUB_TOKEN" -s -d @- https://api.github.com/graphql << GQL
{ "query": "
  query {
    viewer {
      login
    }
  }
" }
GQL
)

echo $data | jq -r .data.viewer.login



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

