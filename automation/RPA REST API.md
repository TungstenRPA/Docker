# REST API for Management Console

* Upload a robot 
```
curl -u ${USERNAME}:${PASSWORD} -X POST "http://${HOST}:/api/mc/robot/add" -F fileField=@${FILEPATH}${FILENAME} - F projectId="13" -F commitMessage="" -F folderName="" -F override="false"
```
* change Admin password
```
curl -u admin:admin -X PUT -H "Content-Type: text/plain" --data "{\"newPassword":\"${PASSWORD}\",\"sendEmail\":false,\"username\":\"admin\",\"oldPassword\":\"admin\"}" "http://${HOST}:/api/mc/user/resetPassword"
```
* create user
```
curl -u admin:admin -X POST -H "Content-Type: text/plain" --data "{"emailAddress":"david.wright@kofax.com","fullName":"david wright","password":"erikl","userName":"david","groupNames":["Developers"]}" "http://${HOST}:/api/mc/user/add"
```
* create group and add user

* create project
```
curl -u admin:admin -X POST -H "Content-Type: text/plain" --data "${JSON}" "http://${HOST}:/api/mc/project/add"
```
```JSON
{
  "accessControl": "",
  "authenticateRest": false,
  "description": "",
  "forceServiceCluster": false,
  "mappings": [
    {
      "roleName": "Kapplet User",
      "groupName": "Kapplet Users",
      "id": -1,
      "projectId": null
    },
    {
      "roleName": "Kapplet Administrator",
      "groupName": "Project Administrators",
      "id": -1,
      "projectId": null
    },
    {
      "roleName": "Developer",
      "groupName": "Developers",
      "id": -1,
      "projectId": null
    },
    {
      "roleName": "RoboServer",
      "groupName": "Roboservers",
      "id": -1,
      "projectId": null
    }
  ],
  "name": "projectname",
  "serviceClusterName": "Production",
  "vcsSettings": {
    "url": "",
    "branch": "",
    "readOnly": false,
    "enabled": false,
    "syncOAuth": false,
    "syncResources": false,
    "syncRobotsTypesSnippets": false,
    "syncSchedules": false
  }
}```
