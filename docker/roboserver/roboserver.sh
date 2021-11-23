#!/usr/bin/env bash

# What until the management console has created the roboserver user account
# before starting the roboserver

while :
do
    echo check if Management Console has created Roboserver account
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
