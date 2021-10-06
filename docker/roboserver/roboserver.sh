#!/usr/bin/env bash

# What until the management console has created the roboserver user account
# before starting the roboserver

while :
do
    echo check if Management Console has created Roboserver account
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -u ${ROBOSERVER_MC_USERNAME}:${ROBOSERVER_MC_PASSWORD} http://localhost:8080/api/mc/cluster/clusters )
    if test ${HTTP_STATUS} = 200 ; then
        break
    fi
    echo sleeping...
    sleep 2
done
echo Roboserver can log into Management Console


${KAPOW_HOME}/bin/RoboServer $@
