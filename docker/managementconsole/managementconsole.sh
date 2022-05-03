#!/usr/bin/env bash

if [ ! -f /usr/local/tomcat/conf/configured.lck ]; then

   # Download JDBC drivers if specified
   targetDir="/usr/local/tomcat/lib/jdbc"
   for i in `seq 1 9`; do
     envName="JDBC_DRIVER_URL_${i}"
     if [[ -z "${!envName}" ]]; then
       break
     fi
     fileName="${!envName##*/}"
     fileName="${targetDir}/${fileName%%\?*}"
     if [[ ! -f "$fileName"  ]]; then
       curl "${!envName}" --output "${fileName}" --silent --fail
       rc=$?; if [[ $rc != 0 ]]; then
         echo "Driver download from ${!envName} failed: $rc"
         exit $rc
       fi
     fi
   done

   # generate a key store for Mysql Connector.
   # the ca.pem file exists in the "mysql" docker image.
   # The key store and the password will be passed then as a parameter to Mysql Connector URL,
   # see CONTEXT_RESOURCE_URL environment variable in the docker-compose-basic.yml
   if [ -f /var/secret/ca.pem ]; then
     if [ -f /usr/local/tomcat/truststore ]; then
       rm /usr/local/tomcat/truststore
     fi
     keytool -importcert -alias MySQLCACert -file /var/secret/ca.pem  -keystore /usr/local/tomcat/truststore -storepass password -noprompt
   fi

   java -cp /usr/local/tomcat/lib/jdbc/*:/managementConsoleConfigurator.jar com.kapowtech.configure.ManagementConsoleConfigurator
   # exit if configurator failed
   rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
   # otherwise make sure it does not run again
   touch /usr/local/tomcat/conf/configured.lck

   if [ ! -z $SLEEP_DELAY ]; then
     sleep $SLEEP_DELAY
   fi
fi

catalina.sh $@
