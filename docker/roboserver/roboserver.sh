#!/usr/bin/env bash

MC_Wait()
{
    while :
    do
        echo Ping Management Console...
        MC_Ping
        if test $? = 0 ; then
            break
        fi
        echo sleeping...
        sleep 2
    done
    echo Management Console is ready.
}
# See if Management Console is alive
MC_Ping()
{
   #Wait a max of 3 seconds to connect to MC
    curl -m 3 -s --fail ${ROBOSERVER_MC_URL}Ping | grep "<string>application<\/string>" || return 1
}
# check
MC_Cluster_GetId()
{
    clusterName=$1
    clusters=$(curl -u ${USERNAME}:${PASSWORD} ${ROBOSERVER_MC_URL}api/mc/cluster/clusters)
    reg='"id":([0-9]+).*?"name":"(.*?)",'
    [[ ${clusters} =~ $reg ]]
    clusterid= ${BASH_REMATCH[1]}
    echo clusterid
    #"id":35,"uniqueKey":"C35","reportedLicense":"Non Production","runningRobots":0,"queuedRobots":0,"maxQueue":null,"runRobotAmount":0,"name":"Non Production"
    #regex=\"id\":\"(\\d+)\"^}+\"name\":\"(^\"+)\"
}

MC_IsRestored()
{ 
   local clusterId=$1
   echo Checking that cluster ${clusterId} is using PostgresSQL as the database...
   curl -s --fail ${ROBOSERVER_MC_USERNAME}:${ROBOSERVER_MC_PASSWORD} -u --fail ${ROBOSERVER_MC_URL}api/mc/cluster/${clusterId}/getClusterSettings | grep '"type":"PostgreSQL"' || return 1
}

if [ ! -f "${KAPOW_HOME}/data/Configuration/roboserver.settings" ]; then
   # run ConfigureMC to get (most of) the data-folder created
   ${KAPOW_HOME}/bin/ConfigureRS 1> /dev/null 2>&1
   # then we can (re-)configure
   ${KAPOW_HOME}/jre/bin/java -jar /roboServerConfigurator.jar
fi

# Wait until Management Console has been restored before connecting
# MC_Wait
# clusterid=$(MC_Cluster_GetId ${ROBOSERVER_MC_CLUSTER} )
# while :
#     do
#         echo Check if Cluster ${ROBOSERVER_MC_CLUSTER}:${clusterId} is restored...
#         MC_IsRestored ${clusterid}
#         if test $? = 0 ; then
#             break
#         fi
#         echo sleeping...
#         sleep 2
#     done
#     echo Management Console is ready.
# MC_IsRestored(${clusterid})
# echo MC restore is complete, safe to start Roboserver
${KAPOW_HOME}/bin/RoboServer $@
