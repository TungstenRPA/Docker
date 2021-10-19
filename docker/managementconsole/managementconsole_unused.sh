# contains unused webservice calls to Management Console

#Wait for Management Console to load
MC_Wait()
{
    while :
    do
        echo Check if Management Console has fully started by getting all users
        curl -s -u ${USERNAME}:${PASSWORD} http://localhost:8080/api/mc/user/page && break
        echo sleeping...
        sleep 2
    done
    echo ; echo Management Console is ready.
}
# See if Management Console is alive. This works before database connectivity is there
MC_Ping()
{
    curl -s  ${MC}/Ping | grep "<string>application<\/string>" || return 1
}
# This only works when MC is completely loaded and configured.

MC_User_Exists()
{
    echo Check User ${USER_NAME} exists 
    echo curl -s -u ${USERNAME}:${PASSWORD} "${MC}/api/mc/user/page"  grep "${USERNAME}" return 1
         curl -s -u ${USERNAME}:${PASSWORD} "${MC}/api/mc/user/page" | grep '"${USERNAME}" || return' 1
}

MC_Change_Password()
{
    echo Change password $@
    un=$1; oldPassword=$2; newPassword=$3
    echo \{\"newPassword\":\"${newPassword}\",\"sendEmail\":false,\"username\":\"${un}\",\"oldPassword\":\"${oldPassword}\"\} > .json
    MC_REST PUT "/api/mc/user/resetPassword" "-H Content-Type:application/json" "--data @.json"
}
    echo MC Restore from Backupfile=${Backupfile}
    MC_REST POST "/secure/Restore" "-F fileField=@${Backupfile} -F restoreMode=Reset" || return 1
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
MC_Add_Group()
{
    # {"id":null,"name":"Roboservers","description":"Roboservers","userNames":["david"]}
    group=$1; description=$2; users=$3
    echo \{\"id\":null,\"name\":\"${group}\",\"description\":\"${description}\",\"userNames\":\[${users}\]\} > .json
    MC_REST POST "/api/mc/user/group/add" "-H Content-Type:application/json" "--data @.json" 
}
