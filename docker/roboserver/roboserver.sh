#!/usr/bin/env bash

if [ ! -f "${KAPOW_HOME}/data/Configuration/roboserver.settings" ]; then

   # Download JDBC drivers if specified
   targetDir="${KAPOW_HOME}/lib/jdbc"
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

   # run ConfigureMC to get (most of) the data-folder created
   ${KAPOW_HOME}/bin/ConfigureRS 1> /dev/null 2>&1
   # then we can (re-)configure
   ${KAPOW_HOME}/jre/bin/java -jar /roboServerConfigurator.jar
fi

${KAPOW_HOME}/bin/RoboServer $@
