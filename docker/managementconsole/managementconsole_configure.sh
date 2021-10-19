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

cd ${KAPOW_HOME}/backup
zip -r backup.zip *
echo Backup package zipped
while :
    do
        MC_Restore ${KAPOW_HOME}/backup/backup.zip && break
        echo Failed to restore. sleep and try again ...
        sleep 2
    done
echo Backup restored to MC

echo Adding Users
MC_Add_User "\"${DEV_NAME}\"" "\"${DEV_PASSWORD}\"" "\"${DEV_FULLNAME}\"" "\"${DEV_EMAIL}"\" '"RPA Administrators","Developers","KappletAdmins","KappletUsers"'
MC_Add_User "\"${ROBOSERVER_MC_USERNAME}\"" "\"${ROBOSERVER_MC_PASSWORD}\"" "'Roboserver'" "roboserver@rpa.com" '"Roboservers"'
MC_Add_User "\"${SYNCH_MC_USERNAME}\"" "\"${SYNCH_MC_PASSWORD}\"" "'Synchronizer'" "synch@rpa.com" '"Synchronizers"'

#Queue test robot to run it
curl =u -u ${USERNAME}:${PASSWORD} -X POST "${MC}/api/mc/tasks/queueRobot" -H  "accept: */*" -H  "Accept-Language: en" -H  "Content-Type: application/json" -d "{  \"priority\": \"MEDIUM\",  \"robotInfo\": {    \"projectName\": \"Default project\",    \"robotName\": \"Tutorials/NewsMagazine.robot\"  },  \"robotInputConfig\":{  \"inputObjects\": []},  \"stopOnError\": true,  \"timeout\": 600}"

touch /usr/local/tomcat/bin/configured
echo Management Console configured with users, groups and roles
