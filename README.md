Red Hat CloudForms Install Demo
===============================
Install your very own local instance of the Red Hat CloudForms product, the management tool of choice for Red Hat Cloud Suite infrastructure solutions. 


Install on your machine
-----------------------
1. First ensure you have an OpenShift container based installation, such as one of the following installed first:

  - [OCP Install Demo](https://github.com/redhatdemocentral/ocp-install-demo)

  - [Red Hat Container Development Kit (CDK) using Minishift](https://developers.redhat.com/products/cdk/overview)

  - or your own OpenShift installation.

2. [Download and unzip.](https://github.com/redhatdemocentral/rhcs-cloudforms-demo/archive/master.zip)

3. Run 'init.sh' or 'init.bat' file. 'init.bat' must be run with Administrative privileges:
```
   # The installation needs to be pointed to a running version
   # of OpenShift, so pass an IP address such as:
   #
   $ ./init.sh 192.168.99.100  # example for OCP.
```

4. Follow displayed instructions to log in to your brand new Red Hat CloudForms!


Notes
-----
Before the log in interface to CloudForms will be available, it takes around 5-10 minutes to populate the containers database. When
it is done, log in to CloudForms web interface (where YOUR-HOST-IP is generated during the installation):

   - http://cloudforms-cloudforms.YOUR-HOST-IP.nip.io

```
     username: admin
     password: smartvm
```
   
   - http://cloudforms-cloudforms.YOUR-HOST-IP.nip.io/self_service

```
     username: admin
     password: smartvm
```

How to add a container provider to start collecting metrics:

1. Log in to CloudForms console.

2. Hover on menu items COMPUTE -> CONTAINERS -> PROVIDERS (click on this last one only to open).

3. Click on CONFIGURATION menu at top to select ADD EXISTING CONTAINERS PROVIDER.

4. Fill in the form as follows:

```
   Name: OCP
   Type: OpenShift Container Platform
   Zone: default

   Default Endpoint:

     Secuirty Protocol: SSL without validation
     Hostname         : kubernetes.default
     API Port         : 443
     Token            : (see command output below)
     Confirm Token    : (see command output below)
```

To lookup the token us the OpenShift CLI tool 'oc' from a terminal window:

``` 
   $ oc login OCP_HOST_IP:8443 -u system:admin

   $ oc serviceaccounts get-token cfme -n cloudforms
```

Paste the token output into the fields mentioned above to complete the form and click on VALIDATE button. Once successful click on
ADD button. An OCP container provider should appear and given time presents data as shown in image below.


Supporting Articles
-------------------
- [Zero to Cloud Operations on OpenShift in minutes](http://www.schabell.org/2017/09/zero-to-cloud-ops-on-openshift-in-minutes.html)

- [3 Steps to Cloud Operations Happiness with CloudForms](http://www.schabell.org/2017/01/3-steps-to-cloud-operations-happiness-with-cloudforms.html)


Released versions
-----------------
See the tagged releases for the following versions of the product:

- v1.3 - Red Hat CloudForms 4.5 containerized and running on OpenShift Container Platform and available on CDK with Minishift.

- v1.2 - Red Hat CloudForms 4.5 containerized and running on any OpenShift Container Platform installation, added windows installation support.

- v1.1 - Red Hat CloudForms 4.5 containerized and running on any OpenShift Container Platform installation.

- v1.0 - Red Hat CloudForms 4.2 containerized and running locally.

![CF Login](https://github.com/redhatdemocentral/rhcs-cloudforms-demo/blob/master/docs/demo-images/cf-login.png?raw=true)

![CF Provider Form](https://github.com/redhatdemocentral/rhcs-cloudforms-demo/blob/master/docs/demo-images/cf-add-provider.png?raw=true)

![CF Provider](https://github.com/redhatdemocentral/rhcs-cloudforms-demo/blob/master/docs/demo-images/cf-container-provider.png?raw=true)

![Cloud Suite](https://github.com/redhatdemocentral/rhcs-cloudforms-demo/blob/master/docs/demo-images/rhcs-arch.png?raw=true)

