Red Hat CloudForms Install Demo
===============================
Install your very own local instance of the Red Hat CloudForms product, the management tool of choice for Red Hat Cloud Suite infrastructure solutions. The CloudForms container 

This project requires a docker engine and some patience for the database to be populated after starting up the containerized CloudForms instance. There will be checks during installation and I point you to what is missing. It also checks that you have the right versions running too.


Install on your machine
-----------------------
----------------------------------
1. First ensure you have an OpenShift container based installation, such as one of the followling installed first:

  - [OCP Install Demo](https://github.com/redhatdemocentral/ocp-install-demo)

  - or your own OpenShift installation.

2. [Download and unzip.](https://github.com/redhatdemocentral/rhcs-cloudforms-demo/archive/master.zip)

3. Run 'init.sh': 
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


Supporting Articles
-------------------
- [3 Steps to Cloud Operations Happiness with CloudForms](http://www.schabell.org/2017/01/3-steps-to-cloud-operations-happiness-with-cloudforms.html)


Released versions
-----------------
See the tagged releases for the following versions of the product:

- v1.1 - Red Hat CloudForms 4.5 containerized and running on any OpenShift Container Platform installation.

- v1.0 - Red Hat CloudForms 4.2 containerized and running locally.

![CF Login](https://github.com/redhatdemocentral/rhcs-cloudforms-demo/blob/master/docs/demo-images/cf-login.png?raw=true)

![CF Mgmt](https://github.com/redhatdemocentral/rhcs-cloudforms-demo/blob/master/docs/demo-images/cf-cloud-intel.png?raw=true)

![Cloud Suite](https://github.com/redhatdemocentral/rhcs-cloudforms-demo/blob/master/docs/demo-images/rhcs-arch.png?raw=true)

