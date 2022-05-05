#!/usr/bin/env bash

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

# What until the management console has created the roboserver user account
# before starting the roboserver

while :
do
    echo Wait until Management Console has created Roboserver account
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -u ${ROBOSERVER_MC_USERNAME}:${ROBOSERVER_MC_PASSWORD} ${ROBOSERVER_MC_URL}api/mc/misc/getVersion )
    if test ${HTTP_STATUS} = 200 ; then
        break
    fi
    echo sleeping...
    sleep 2
done
echo Roboserver can log into Management Console

if [ ! -f "${KAPOW_HOME}/data/Configuration/roboserver.settings" ]; then
   # run ConfigureMC to get (most of) the data-folder created
   ${KAPOW_HOME}/bin/ConfigureRS 1> /dev/null 2>&1
   # then we can (re-)configure
   ${KAPOW_HOME}/jre/bin/java -jar /roboServerConfigurator.jar
fi

exec ${KAPOW_HOME}/bin/RoboServer $@

# potential solution to allow fast killing of roboserver on ecs
#exec ${KAPOW_HOME}/bin/RoboServer $@
# the next command makes the container easier to kill because it will respond to SIGTERM https://aws.amazon.com/blogs/containers/graceful-shutdowns-with-ecs/
#exec "$@"
