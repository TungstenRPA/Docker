#!/usr/bin/env bash
# Add users, groups to MC. Change admin password, configure default project roles and upload robots.
MC=http://localhost:8080
USERNAME=admin
PASSWORD=admin
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo SCRIPT_DIR=${SCRIPT_DIR}
#Wait for Management Console to load
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
    curl -s --fail ${MC}/Ping | grep "<string>application<\/string>" || return 1
}
# Call a POST/GET/PUT REST Webservice on Management Console
MC_REST()
{
    type=$1; path=$2; shift; shift ; data=$@ 
    curl -u ${USERNAME}:${PASSWORD} ${data} -X ${type} "${MC}${path}" 1>/dev/null 2>&1
    rc=$?
    rm -rf .json || true
    if [ $rc != 0 ]; then
        echo "${path} failed with code: ${rc}"
        return 1
    fi
}
MC_Change_Password()
{
    echo Change password $@
    un=$1; oldPassword=$2; newPassword=$3
    echo \{\"newPassword\":\"${newPassword}\",\"sendEmail\":false,\"username\":\"${un}\",\"oldPassword\":\"${oldPassword}\"\} > .json
    MC_REST PUT "/api/mc/user/resetPassword" "-H Content-Type:application/json" "--data @.json"
}
MC_Add_User()
{
    eval un="$1"; eval pw="$2"; eval fullName="$3"; eval email="$4"; groupNames="$5"
    echo \{\"emailAddress\":\"${email}\",\"fullName\":\"${fullName}\",\"password\":\"${pw}\",\"userName\":\"${un}\",\"groupNames\":\[${groupNames}\]\} > .json
    cat .json
    MC_REST POST "/api/mc/user/add" "-H Content-Type:application/json" "--data @.json" 
}
MC_Add_Group()
{
    # {"id":null,"name":"Roboservers","description":"Roboservers","userNames":["david"]}
    group=$1; description=$2; users=$3
    echo \{\"id\":null,\"name\":\"${group}\",\"description\":\"${description}\",\"userNames\":\[${users}\]\} > .json
    MC_REST POST "/api/mc/user/group/add" "-H Content-Type:application/json" "--data @.json" 
}
MC_Restore()
{
    #curl -u ${USERNAME}:${PASSWORD} -F fileField=@${FILEPATH}${FILENAME} -F restoreMode=Reset
    Backupfile=$1;
    echo MC Restore from Backupfile=${Backupfile}
    MC_REST POST "/secure/Restore" "-F fileField=@${Backupfile} -F restoreMode=Reset"
}
MC_Cluster_GetId()
{
    clusterName=$1
    clusters=$(curl -u ${USERNAME}:${PASSWORD} ${MC}//api/mc/cluster/clusters)
    reg='"id":([0-9]+).*?"name":"(.*?)",'
    [[ ${clusters} =~ $reg ]]
    clusterid= ${BASH_REMATCH[1]}
    echo clusterid
    #"id":35,"uniqueKey":"C35","reportedLicense":"Non Production","runningRobots":0,"queuedRobots":0,"maxQueue":null,"runRobotAmount":0,"name":"Non Production"
    #regex=\"id\":\"(\\d+)\"^}+\"name\":\"(^\"+)\"
}
MC_Roboserver_Add()
{
    #{"hostName":"roboserver-service","portNumber":"5000","clusterId":35}
    clusterId=$1;server=$2; port=$3
    echo {"hostName":"roboserver-service","portNumber":"5000","clusterId":35} > .json
    MC_REST POST "/api/mc/cluster/addServer" "-H Content-Type:application/json" "--data @.json"
}
MC_Roboserver_Delete()
{
    #{"hostName":"roboserver-service","portNumber":"5000","clusterId":35}
    server=$1; # 125
    MC_REST PUT "/api/mc/cluster/deleteServer/${server}" ""
}
MC_Add_Robot()
{
    projectID=$1;FILEPATH=$2; FILENAME=$3; folderName=$4
    MC_REST POST "/api/mc/robot/add" -F fileField=@${FILEPATH}${FILENAME} - F projectId="13" -F commitMessage="" -F folderName="${folderName}" -F override="false"
}
# Generate a random password from the current nanosecond
Password_Create(){ < date +%s%N | sha256sum | base64 | head -c${1:-16};echo;}

# check that we have not run before
echo Configuring users, groups and roles in Management Console...
if test -f /usr/local/tomcat/bin/configured ; then 
    echo Management Console already configured
    exit 0
fi
MC_Wait
# MC_Change_Password ${USERNAME} admin ${PASSWORD}
# echo Add Groups
# MC_Add_Group Developers "build robots" ""
# echo add developers
# MC_Add_Group Roboservers "run the robots" ""
# MC_Add_Group Synchronizers "upload and download robots to a Git Repository" ""
# MC_Add_Group KappletAdmins "create and edit Kapplets" ""
# echo add kappletusers
# MC_Add_Group KappletUsers "run Kapplets" ""
# echo Add Users ---
#MC_Add_User synch £tUw_T3 Synch synch@kofax.com '"Synchronizers"'

#clusterid=$(MC_Cluster_GetId "Non Production" )
#MC_Roboserver_Add ${clusterid}  "roboserver-service" "50000"
# MC_Restore /usr/local/tomcat/bin/MC_backup_Postgres.zip

#Create the roboserver user account so that the roboserver can actually get in and auto-register after the MC restore has completed

# MC_Add_User "\"${DEV_NAME}\"" "abc123" "\"${DEV_FULLNAME}\"" "\"${DEV_EMAIL}"\" '"RPA Administrators","Developers","RPA Administrators","KappletAdmins","KappletUsers"'
MC_Add_User "\"${DEV_NAME}\"" "\"${DEV_PASSWORD}\"" "\"${DEV_FULLNAME}\"" "\"${DEV_EMAIL}"\" '"RPA Administrators","Developers","RPA Administrators","KappletAdmins","KappletUsers"'
MC_Add_User "\"${ROBOSERVER_MC_USERNAME}\"" "\"${ROBOSERVER_MC_PASSWORD}\"" "'Roboserver'" "roboserver@rpa.com" '"Roboservers"'
MC_Add_User "\"${SYNCH_MC_USERNAME}\"" "\"${SYNCH_MC_PASSWORD}\"" "'Synchronizer'" "synch@rpa.com" '"Synchronizers"'

# MC_Change_Password "\"${DEV_NAME}\"" "\"${DEV_PASSWORD}\"" "\"abc\""
# MC_Change_Password "\"${DEV_NAME}\"" "\"${DEV_PASSWORD}\"" "\"abc\""

#13 is the id of the "Default Project"
# MC_Add_Robot 13 "/samplerobots/" "abc.robot" ""
# MC_Add_Robot 13 "/samplerobots/" "abc.robot" ""
# MC_Add_Project ...

touch /usr/local/tomcat/bin/configured
echo Management Console configured with users, groups and roles