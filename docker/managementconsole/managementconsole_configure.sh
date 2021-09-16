#!/usr/bin/env bash
# Add users, groups to MC. Change admin password, configure default project roles and upload robots.
MC_REST()
{
    type=$1; url=$2;shift ;shift
    data=$@ 
    curl -u ${USERNAME}:${PASSWORD} ${data} -X ${type} "${url}" 1>/dev/null 2>&1
    rc=$?
    if [[ $rc != 0 ]]; then
        echo "${url} failed with code: ${rc}"
        exit 1
    fi
}
MC_Change_Password()
{
    username=$1; oldPassword=$2; newPassword=$3
    data="--data {\"newPassword\":\"${newPassword}\",\"sendEmail\":false,\"username\":\"${username}\",\"oldPassword\":\"${oldPassword}\"}"
    MC_REST PUT "/api/mc/user/resetPassword" "-H \"Content-Type: text/plain\"" ${data} 
}
MC_Create_User()
{
    userName=$1; password=$2; fullname=$3; email=$4, groupNames=$5
    #jsonify group names
    groupNames=${groupNames/,/],[/}
    data="--data {\"emailAddress\":\"${email}\",\"fullName\":\"${fullName}\",\"password\":\"${password}\",\"userName\":\"${userName}}\",\"groupNames\":${[groupNames]}}"
    echo ${data}
    MC_REST POST "/api/mc/user/add" "Content-Type: text/plain" ${data} 
}

MC_Add_Group()
{
    MC_REST developers
}

MC_Add_Project()
{

}

MC_Add_Robot()
{
    projectID=$1;FILEPATH=$2; FILENAME=$3; folderName=$4
    MC_REST POST "/api/mc/robot/add" -F fileField=@${FILEPATH}${FILENAME} - F projectId="13" -F commitMessage="" -F folderName="${folderName}" -F override="false"
}

MC_Change_Password ${USERNAME} admin ${PASSWORD}
MC_Add_Group Developers
MC_Add_Group Roboservers
MC_Add_Group Synchronizers
MC_Add_Group KappletAdmins
MC_Add_Group KappletUsers
MC_Add_User david £$%(*)$£% "David Wright" david.wright@kofax.com "Developers,RPA Administrators,KappletAdmins,KappletUsers"
MC_Add_User roboserver 4£^6£y Roboserver roboserver@kofax.com Roboservers
MC_Add_User synch £tU%_£3% Synch synch@kofax.com "Synchronizers"

#13 is the id of the "Default Project"
MC_Add_Robot 13 "/samplerobots/" "abc.robot" ""
MC_Add_Robot 13 "/samplerobots/" "abc.robot" ""

MC_Add_Project ...
