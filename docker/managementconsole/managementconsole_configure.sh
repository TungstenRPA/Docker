#!/usr/bin/env bash
# Add users, groups to MC. Change admin password, configure default project roles and upload robots.
MC=http://localhost:8080
USERNAME=admin
PASSWORD=admin
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo SCRIPT_DIR=${SCRIPT_DIR}

# Call a POST/GET/PUT REST Webservice on Management Console
MC_REST()
{
    echo $@
    type=$1; path=$2; shift; shift ; data=$@ 
    test -f .json && cat .json
    echo curl -i -S -u ${USERNAME}:${PASSWORD} ${data} -X ${type} "${MC}${path}"
         curl -i -S -u ${USERNAME}:${PASSWORD} ${data} -X ${type} "${MC}${path}"
    rc=$?
    rm -rf .json || true
    if [ $rc != 0 ]; then
        echo "${path} CURL failed with code: ${rc}"
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
MC_User_Exists()
{
    echo Check User ${USERNAME} exists 
    curl -s -u ${USERNAME}:${PASSWORD} "${MC}/api/mc/user/page" | grep '"${USERNAME}"' || return 1
}

MC_Group_Exists()
{
    echo Check User ${GROUPNAME} exists 
    curl -s -u ${GROUPNAME}:${PASSWORD} "${MC}/api/mc/user/page" | grep '"${GROUPNAME}"' || return 1
}
MC_Add_User()
{
    eval un="$1"; eval pw="$2"; eval fullName="$3"; eval email="$4"; groupNames="$5"
    echo add user ${un}
    echo \{\"emailAddress\":\"${email}\",\"fullName\":\"${fullName}\",\"password\":\"${pw}\",\"userName\":\"${un}\",\"groupNames\":\[${groupNames}\]\} > .json
    MC_REST POST "/api/mc/user/add" "-H Content-Type:application/json" "--data @.json"
}
MC_Restore()
{
    #curl -u ${USERNAME}:${PASSWORD} -F fileField=@${FILEPATH}${FILENAME} -F restoreMode=Reset
    Backupfile=$1;
    echo MC Restore from Backupfile=${Backupfile}
    MC_REST POST "/secure/Restore" "-F fileField=@${Backupfile} -F restoreMode=Reset" || return 1
}

MC_Database_ChangeDomainName()
{
    # MC ignores domain name of database. These adds the domain name. 
    # Get the first ClusterID. This uses jq for JSON
    export CLUSTER_ID=$(curl -S -u ${USERNAME}:${PASSWORD} -X GET "${MC}/api/mc/cluster/clusters" | jq .data[0].id)
    # Correct the cluster database domain name
    curl -s -u ${USERNAME}:${PASSWORD} "${MC}/api/mc/cluster/${CLUSTER_ID}/getClusterSettings" > clusterSettings.json
    jq -r '.databaseSettings[0].host |="postgres-service.DOMAINNAME"' clusterSettings.json > clusterSettings1.json
    jq -r -S '.databaseSettings[0].fileContent |= ""' clusterSettings1.json > clusterSettings2.json
    # upload the corrected database name back to MC
    MC_REST PUT  "/api/mc/cluster/setClusterSettings" "-H Content-Type:application/json" "--data @clusterSettings2.json"
    echo "{\"applyMode\":\"FINISH_SCHEDULES\",\"clusterId\":\"${CLUSTER_ID}\"}" > apply.json
    MC_REST PUT  "/api/mc/cluster/applyClusterSettings" "-H Content-Type:application/json" "--data @apply.json"
}

# check that we have not run before
echo Configuring users, groups and roles in Management Console...
if test -f /usr/local/tomcat/bin/configured ; then 
    echo Management Console already configured
    exit 0
fi


# Wait until the Management console has logged "Server startup in"
while :
    RPA_LOG=/usr/local/tomcat/logs/catalina*
    do
         test -f ${RPA_LOG} || cat ${RPA_LOG} | grep 'Server startup in'  && break
         echo MC still loading...
         sleep 2
    done


echo Zipping Backup package

pushd ${KAPOW_HOME}/backup
zip -r backup.zip *
popd
echo Backup package zipped
while :
    do
        MC_Restore ${KAPOW_HOME}/backup/backup.zip && break
        echo Failed to restore. sleep and try again ...
        sleep 2
    done
echo Backup restored to MC

# Wait until there is only 1 user - the admin user.
while :
    do
        curl -s -u ${USERNAME}:${PASSWORD} "${MC}/api/mc/user/page" | grep -c '"count":1,"page"' && break
        echo not 1 users
        sleep 1
    done
echo all users deleted

#Wait until all 6 groups are created
while :
    do
        curl -s -u ${USERNAME}:${PASSWORD} "${MC}/api/mc/user/group/page" | grep '"count":6,"page"' && break
        echo not 6 groups
        sleep 1
    done
echo 6 groups created
echo Adding Users
echo Adding user ${DEV_NAME}
MC_Add_User "\"${DEV_NAME}\"" "\"${DEV_PASSWORD}\"" "\"${DEV_FULLNAME}\"" "\"${DEV_EMAIL}"\" '"RPA Administrators","Developers","KappletAdmins","KappletUsers"'
echo Adding user roboserver
MC_Add_User "\"${ROBOSERVER_MC_USERNAME}\"" "\"${ROBOSERVER_MC_PASSWORD}\"" "'Roboserver'" "roboserver@rpa.com" '"Roboservers"'
echo Adding user synch
MC_Add_User "\"${SYNCH_MC_USERNAME}\"" "\"${SYNCH_MC_PASSWORD}\"" "'Synchronizer'" "synch@rpa.com" '"Synchronizers"'

# Change cluster database Host name to fully qualified version
MC_Database_ChangeDomainName

#Queue test robot to run it
curl =u -u ${USERNAME}:${PASSWORD} -X POST "${MC}/api/mc/tasks/queueRobot" -H  "accept: */*" -H  "Accept-Language: en" -H  "Content-Type: application/json" -d "{  \"priority\": \"MEDIUM\",  \"robotInfo\": {    \"projectName\": \"Default project\",    \"robotName\": \"Tutorials/NewsMagazine.robot\"  },  \"robotInputConfig\":{  \"inputObjects\": []},  \"stopOnError\": true,  \"timeout\": 600}"
rm .json || true
echo Queued robot Tutorials/NewsMagazine.robot
touch /usr/local/tomcat/bin/configured
echo Management Console configured with users, groups and roles
