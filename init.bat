@ECHO OFF
setlocal

set PROJECT_HOME=%~dp0
set AUTHORS=Michael Surbey, Eric D. Schabell
set PROJECT=git@github.com:redhatdemocentral/rhcs-cloudforms-demo.git
set DOCKER_MAJOR_VER=17
set DOCKER_MINOR_VER=06
set OC_MAJOR_VER=v3
set OC_MINOR_VER=5

REM Adjust these variables to point to an OCP instance.
set OPENSHIFT_USER=admin
set OPENSHIFT_PWD=admin
set HOST_IP=yourhost.com
set OCP_PRJ=cloudforms
set CF_IMAGE_TEMPLATE=https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_examples/files/examples/v3.6/cfme-templates/cfme-template.yaml

REM wipe screen.
cls

echo.
echo #####################################################################
echo ##                                                                 ##   
echo ##  Setting up your very own                                       ##
echo ##                                                                 ##   
echo ##    #### #      ###  #   # ####  #####  ###  ##### #   #  ####   ##
echo ##   #     #     #   # #   # #   # #     #   # #   # ## ## #       ##
echo ##   #     #     #   # #   # #   # ####  #   # ##### # # #  ###    ##
echo ##   #     #     #   # #   # #   # #     #   # #  #  #   #     #   ## 
echo ##    #### #####  ###   ###  ####  #      ###  #   # #   # ####    ##
echo ##                                                                 ##   
echo ##  %GIT_REPO%      ##
echo ##                                                                 ##
echo ##  Contributors: %AUTHORS%                 ##
echo ##                                                                 ##
echo #####################################################################
echo.

REM Validate OpenShift 
set argTotal=0

for %%i in (%*) do set /A argTotal+=1

if %argTotal% EQU 1 (

    call :validateIP %1 valid_ip

	if !valid_ip! EQU 0 (
	    echo OpenShift host given is a valid IP...
	    set HOST_IP=%1
		echo.
		echo Proceeding with OpenShift host: !HOST_IP!...
	) else (
		echo Please provide a valid IP that points to an OpenShift installation...
		echo.
        GOTO :printDocs
	)

)

if %argTotal% GTR 1 (
    GOTO :printDocs
)


REM make some checks first before proceeding.	
call where oc >nul 2>&1
if  %ERRORLEVEL% NEQ 0 (
	echo OpenShift command line tooling is required but not installed yet... download here:
	echo https://access.redhat.com/downloads/content/290
	GOTO :EOF
)

echo OpenShift commandline tooling is installed...
echo.
echo Logging in to OpenShift as %OPENSHIFT_USER%...
echo.
call oc login %HOST_IP%:8443 --password="%OPENSHIFT_PWD%" --username="%OPENSHIFT_USER%"

if not "%ERRORLEVEL%" == "0" (
  echo.
	echo Error occurred during 'oc login' command!
	echo.
	GOTO :EOF
)

echo.
echo Creating a new project...
echo.
call oc new-project %OCP_PRJ%

echo.
echo Logging in to OpenShift as system admin...
echo.
call oc login %HOST_IP%:8443 -u system:admin

if not "%ERRORLEVEL%" == "0" (
  echo.
	echo Error occurred during 'oc login' as admin command!
	echo.
	GOTO :EOF
)

echo. 
echo Creating service account for CloudForms...
echo.
call oc create serviceaccount cfme -n %OCP_PRJ%

if not "%ERRORLEVEL%" == "0" (
  echo.
	echo Error occurred creating service account for CloudForms!
	echo.
	GOTO :EOF
)

echo. 
echo Granting service account cluster-admin access to CloudForms...
echo.
call oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:cloudforms:cfme

if not "%ERRORLEVEL%" == "0" (
  echo.
	echo Error occurred granting service account cluster-admin access!
	echo.
	GOTO :EOF
)

echo.
echo Adding policy for service account to run CloudForms...
echo. 
call oc adm policy add-scc-to-user anyuid system:serviceaccount:cloudforms:cfme-anyuid

if not "%ERRORLEVEL%" == "0" (
  echo.
	echo Error occurred during adding policy for service account!
	echo.
	GOTO :EOF
)

echo.
echo Setting policy privileges for running CloudForms...
echo. 
call oc adm policy add-scc-to-user privileged system:serviceaccount:cloudforms:default

if not "%ERRORLEVEL%" == "0" (
  echo.
	echo Error occurred during setting policy privileges for service account!
	echo.
	GOTO :EOF
)

echo
echo Importing CloudForms image template...
echo
call oc create -f %CF_IMAGE_TEMPLATE% -n openshift

echo.
echo Logging in to OpenShift as %OPENSHIFT_USER%...
echo.
call oc login %HOST_IP%:8443 --username=%OPENSHIFT_USER% --password=%OPENSHIFT_PWD%

if not "%ERRORLEVEL%" == "0" (
  echo.
	echo Error occurred during 'oc login' command!
	echo.
	GOTO :EOF
)

echo.
echo Installing CloudForms...
echo.
call oc new-app -p=APPLICATION_MEM_REQ=3072Mi --template=%OCP_PRJ% -n %OCP_PRJ%
						
if not "%ERRORLEVEL%" == "0" (
	echo.
	echo Error occurred during install of CloudForms!
  echo.
	GOTO :EOF
)

echo.
echo ================================================================
echo =                                                              =
echo = Install complete, get ready to rock your new Red Hat         = 
echo = CloudForms management engine.                                =
echo =                                                              =
echo = The CloudForms log in is accessible via web at:              =
echo =                                                              =
echo =  https://cloudforms-cloudforms.%HOST_IP%.nip.io     =
echo =                                                              =
echo =  Log in as:                                                  =
echo =                                                              =
echo =      username: admin                                         =
echo =      password: smartvm                                       =
echo =                                                              =
echo =  Self service login at:                                      =
echo =                                                              =
echo =  https://cloudforms-cloudforms.%HOST_IP%.nip.io/self_service  =
echo =                                                              =
echo =      username: admin                                         =
echo =      password: smartvm                                       =
echo =                                                              =
echo =  Note: it will take a few mintues for CloudForms to become   =
echo =  fully available, so login to Openshift connsole and watch   =
echo =  the deployments spin up.                                    =
echo =                                                              =
echo ================================================================
echo.

GOTO :EOF
      

:validateIP ipAddress [returnVariable]

    setlocal 

    set "_return=1"

    echo %~1^| findstr /b /e /r "[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*" >nul

    if not errorlevel 1 for /f "tokens=1-4 delims=." %%a in ("%~1") do (
        if %%a gtr 0 if %%a lss 255 if %%b leq 255 if %%c leq 255 if %%d gtr 0 if %%d leq 254 set "_return=0"
    )

:endValidateIP

    endlocal & ( if not "%~2"=="" set "%~2=%_return%" ) & exit /b %_return%
	
:printDocs
  echo This project can be installed on any OpenShift platform. It's possible to
  echo install it on any available installation by pointing this installer to an
  echo OpenShift IP address:
  echo.
  echo   $ ./init.sh IP
  echo.
  echo If using Red Hat OCP, IP should look like: 192.168.99.100
  echo.

