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
    user=$1; oldpassword=$2; newpassword=$3
    data="--data {\"newPassword\":\"${newpassword}\",\"sendEmail\":false,\"username\":\"${username}\",\"oldPassword\":\"${oldpassword}\"}"
    MC_REST PUT "/api/mc/user/resetPassword" "-H \"Content-Type: text/plain\"" ${data} 
}
MC_Create_User()
{
    userName=$1; password=$2; fullname=$3; email=$4, GroupNames=$5
    data="--data {\"emailAddress\":\"${email}\",\"fullName\":\"${fullName}\",\"password\":\"${password}\",\"userName\":\"${userName}}\",\"groupNames\":${GroupNames}}"
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

MC_Change_Password admin admin 2308ewtro32
MC_Add_Group developers
MC_Add_Group roboservers
MC_Add_Group synchronizers
MC_Add_Group kappletadmins
MC_Add_Group kappletusers
MC_Add_User david £$%(*)$£% "David Wright" david.wright@kofax.com ["Developers"],["admin"],["kappletadmins"],["kappletusers"]
MC_Add_User roboserver "£$"£$ Roboserver roboserver@kofax.com ["Roboservers"]
MC_Add_User synch £$%)£$% Synch synch@kofax.com ["Synchronizers"]
MC_Add_Robot 13 "/samplerobots/" "abc.robot" ""
MC_Add_Robot 13 "/samplerobots/" "abc.robot" ""

MC_Add_Project ...
