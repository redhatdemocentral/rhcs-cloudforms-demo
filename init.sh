#!/bin/sh 

AUTHORS="Michael Surbey, Eric D. Schabell"
DOCKER_MAJOR_VER=1
DOCKER_MINOR_VER=10
OC_MAJOR_VER="v3"
OC_MINOR_VER=3
GIT_REPO="https://github.com/redhatdemocentral/rhcs-cloudforms-demo"
CF_WEB="https://localhost"

# wipe screen.
clear 

echo
echo "#####################################################################"
echo "##                                                                 ##"   
echo "##  Setting up your very own                                       ##"
echo "##                                                                 ##"   
echo "##    #### #      ###  #   # ####  #####  ###  ##### #   #  ####   ##"
echo "##   #     #     #   # #   # #   # #     #   # #   # ## ## #       ##"
echo "##   #     #     #   # #   # #   # ####  #   # ##### # # #  ###    ##"
echo "##   #     #     #   # #   # #   # #     #   # #  #  #   #     #   ##" 
echo "##    #### #####  ###   ###  ####  #      ###  #   # #   # ####    ##"
echo "##                                                                 ##"   
echo "##  $GIT_REPO      ##"
echo "##                                                                 ##"   
echo "##  Contributors: $AUTHORS                 ##"
echo "##                                                                 ##"   
echo "#####################################################################"
echo

# Ensure docker engine available.
#
command -v docker -h >/dev/null 2>&1 || { echo >&2 "Docker is required but not installed yet... download here: https://www.docker.com/products/docker"; exit 1; }
echo "Docker is installed... checking for valid version..."
echo
		
# Check docker enging version.
dockerverone=$(docker version -f='{{ .Client.Version }}' | awk -F[=.] '{print $1}')
dockervertwo=$(docker version -f='{{ .Client.Version }}' | awk -F[=.] '{print $2}')
if [ $dockerverone -eq $DOCKER_MAJOR_VER ] && [ $dockervertwo -ge $DOCKER_MINOR_VER ]; then
	echo "Valid version of docker engine found... $dockerverone.$dockervertwo"
	echo
else
	echo "Docker engine version $dockerverone.$dockervertwo found... need 1.10+, please update: https://www.docker.com/products/docker"
	echo
	exit
fi

echo "Installing CloudForms container into your registry..."
echo
docker pull ecwpz91/cfme4-demo

if [ $? -ne 0 ]; then
		echo
		echo Error occurred during 'docker pull' command!
		echo
		exit
fi

echo
echo "Starting the CloudForms container..."
echo
docker run --privileged -di -p 80:80 -p 443:443 --name cfme4-demo ecwpz91/cfme4-demo

if [ $? -ne 0 ]; then
		echo
		echo "Error occurred during 'docker run' command!"
		echo
		echo "Cleaning out existing container in registry..."
		echo
		docker stop cfme4-demo
		echo
	  docker rm cfme4-demo
		echo 
		echo "Restarting the CloudForms container..."

		if [ $? -ne 0 ]; then
			echo
			echo "Problem with installation that I can't resolve, please raise an issue and add error output:"
			echo
			echo "   $GIT_REPO/issues/new" 
			echo
			exit
		fi
fi

echo
echo "====================================================="
echo "=                                                   ="
echo "= Install complete, get ready to rock your new      ="
echo "= Red Hat CloudForms management engine.             ="
echo "=                                                   ="
echo "=  The CloudForms log in is accessible via web at:  ="
echo "=                                                   ="
echo "=	   $CF_WEB                        ="
echo "=                                                   ="
echo "=  NOTE: it takes 5-10 minutes for database to      ="
echo "=        populate, at which time the log in will    ="
echo "=        become available... be patient...          ="
echo "=                                                   ="
echo "=  Log in as:                                       ="
echo "=                                                   ="
echo "=    Admin user: admin                              ="
echo "=      password: smartvm                            ="
echo "=                                                   ="
echo "=    Operations user: cloudops                      ="
echo "=           password: Redhat1!                      ="
echo "=                                                   ="
echo "=    Customer user: clouduser                       ="
echo "=         password: Redhat1!                        ="
echo "=                                                   ="
echo "=  If you want to save the machine and restart it   ="
echo "=  next time, don't use init.sh, instead:           ="
echo "=                                                   ="
echo "=     $ docker stop cfme4-demo                      ="
echo "=                                                   ="
echo "=     $ docker start cfme4-demo                     ="
echo "=                                                   ="
echo "===================================================="
echo
