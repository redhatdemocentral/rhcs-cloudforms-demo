#!/bin/sh 

AUTHORS="Michael Surbey, Eric D. Schabell"
DOCKER_MAJOR_VER=17
DOCKER_MINOR_VER=06
OC_MAJOR_VER="v3"
OC_MINOR_VER=5
GIT_REPO="https://github.com/redhatdemocentral/rhcs-cloudforms-demo"

# Adjust these variables to point to an OCP instance.
OPENSHIFT_USER=admin
OPENSHIFT_PWD=admin
HOST_IP=yourhost.com
OCP_PRJ=cloudforms
CF_IMAGE_TEMPLATE="https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/v3.6/cfme-templates/cfme-template.yaml"

# prints the documentation for this script.
function print_docs() 
{
	echo "This project can be installed on any OpenShift platform, such as the OpenShift Container"
	echo "Platform (OCP). It is possible to install it on any available installation, just point"
	echo "this installer at your installation by passing an IP of your OpenShift installation:"
	echo
	echo "   $ ./init.sh IP"
	echo
	echo "If using Red Hat OCP, IP should look like: 192.168.99.100"
	echo
}

# check for a valid passed IP address.
function valid_ip()
{
	local  ip=$1
	local  stat=1

	if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		OIFS=$IFS
		IFS='.'
		ip=($ip)
		IFS=$OIFS
		[[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
		stat=$?
	fi

	return $stat
}

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

# validate OpenShift host IP.
if [ $# -eq 1 ]; then
	if valid_ip "$1" || [ "$1" == "$HOST_IP" ]; then
		echo "OpenShift host given is a valid IP..."
		HOST_IP=$1
		echo
		echo "Proceeding with OpenShift host: $HOST_IP..."
		echo
	else
		# bad argument passed.
		echo "Please provide a valid IP that points to an OpenShift installation..."
		echo
		print_docs
		echo
		exit
	fi
elif [ $# -gt 1 ]; then
	print_docs
	echo
	exit
else
	# no arguments, prodeed with default host.
	print_docs
	echo
	exit
fi


# make some checks first before proceeding.	
command -v oc -v >/dev/null 2>&1 || { echo >&2 "OpenShift command line tooling is required but not installed yet... download here: https://access.redhat.com/downloads/content/290"; exit 1; }

echo "OpenShift commandline tooling is installed..."
echo
echo "Logging in to OpenShift as $OPENSHIFT_USER..."
echo
oc login $HOST_IP:8443 --password=$OPENSHIFT_PWD --username=$OPENSHIFT_USER

if [ "$?" -ne "0" ]; then
	echo
	echo "Error occurred during 'oc login' command!"
	exit
fi
									
echo
echo "Creating a new project..."
echo
oc new-project $OCP_PRJ
	
echo
echo "Logging in to OpenShift as system admin..."
echo
oc login $HOST_IP:8443 -u system:admin

if [ "$?" -ne "0" ]; then
	echo
	echo "Error occurred during 'oc login' as system admin command!"
	exit
fi

echo
echo "Adding policy for service account to run CloudForms..."
echo 
oc adm policy add-scc-to-user anyuid system:serviceaccount:cloudforms:cfme-anyuid

if [ "$?" -ne "0" ]; then
	echo
	echo "Error occurred during adding policy for service account!"
	exit
fi

echo
echo "Setting policy privileges for running CloudForms..."
echo 
oc adm policy add-scc-to-user privileged system:serviceaccount:cloudforms:default

if [ "$?" -ne "0" ]; then
	echo
	echo "Error occurred during setting policy privileges for service account!"
	exit
fi

echo 
echo "Importing CloudForms image template..."
echo 
oc create -f $CF_IMAGE_TEMPLATE -n openshift

if [ "$?" -ne "0" ]; then
	echo
	echo "Error occurred during importing CloudForms image template!"
	exit
fi

echo
echo "Logging in to OpenShift as $OPENSHIFT_USER..."
echo
oc login $HOST_IP:8443 --username=$OPENSHIFT_USER --password=$OPENSHIFT_PWD

if [ "$?" -ne "0" ]; then
	echo
	echo "Error occurred during 'oc login' command!"
	exit
fi

echo
echo "Installing CloudForms..."
echo

oc new-app -p=APPLICATION_MEM_REQ=3072Mi --template=$OCP_PRJ
						
if [ "$?" -ne "0" ]; then
	echo
	echo "Error occurred during install of CloudForms!"
	exit
fi

echo "================================================================"
echo "=                                                              ="
echo "= Install complete, get ready to rock your new Red Hat         =" 
echo "= CloudForms management engine.                                ="
echo "=                                                              ="
echo "= The CloudForms log in is accessible via web at:              ="
echo "=                                                              ="
echo "=  https://cloudforms-cloudforms.$HOST_IP.nip.io     ="
echo "=                                                              ="
echo "=  Log in as:                                                  ="
echo "=                                                              ="
echo "=      username: admin                                         ="
echo "=      password: smartvm                                       ="
echo "=                                                              ="
echo "=  Self service login at:                                      ="
echo "=                                                              ="
echo "=  https://cloudforms-cloudforms.$HOST_IP.nip.io/self_service  ="
echo "=                                                              ="
echo "=      username: admin                                         ="
echo "=      password: smartvm                                       ="
echo "=                                                              ="
echo "================================================================"
echo
