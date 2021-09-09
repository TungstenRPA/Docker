# Docker

# Create Docker Image
1. Download Docker Desktop.
2. Download Linux for Windows inside Docker.
3. Download Linux RPA.
4. Unzip RPA linux with **tar -xf KofaxRPA-11.2.0.2.tar.gz**
5. CD to unzip directory
6. **copy docker\compose-examples\docker-compose-basic.yml docker-compose.yml**
7. View Docker File in Visual Studio Code with **code docker\managementconsole\Dockerfile**
8. Create Docker Image with **docker compose -p rpa_11.2.0.2 up -d**.   
  * "-p" project name (default is directory name)
  * "up" create and dostart it
  * "-d" means to detatch it from the console to get the cursor back.

# Add Docker Image to Amazon Repository
1. Download [https://aws.amazon.com/cli/](Amazon%20Web%20Services%20Command%20Line%20Interface)
2. Login to [https://aws.amazon.com/](Amazon%20Webservices)
3. Select your region.
4. [Push the Docker Image](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html)
   * [Create](https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-create.html) a [private repository](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html) for **managementconsole**, **roboserver**, **kapplets**, etc..
   * click **View push commands** to get the command lines to upload the image.
   * [create a user](https://docs.aws.amazon.com/AmazonECR/latest/userguide/get-set-up-for-amazon-ecr.html) and group with **AdministratorAccess** at [IAM](https://console.aws.amazon.com/iam)
   * [configure CLI access to AWI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html) with your credentials by typing **asw configure**
   * login to aws with **aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 022336740566.dkr.ecr.eu-central-1.amazonaws.com**
   * tag the image as latest so Docker knows where to push it: **docker tag managementconsole:latest 022336740566.dkr.ecr.eu-central-1.amazonaws.com/console:latest**
   * push the image to the Repository in AWS. **docker push 022336740566.dkr.ecr.eu-central-1.amazonaws.com/kofaxrpa:latest**
   * push the image also with the version tag. **docker push 022336740566.dkr.ecr.eu-central-1.amazonaws.com/kofaxrpa:11.2.0.2** and you will see both tags.
![image](https://user-images.githubusercontent.com/47416964/132709793-cd5edd48-ab6c-4397-9f84-3f8f5e85bb38.png)

# Phase 1 - POC
* Image in AWS Repo
* Postgres internal, MC & Roboserver
* Admin password changed
* Non Production cluster
* Roboserver logging to Postgres

# Phase 2 - Sharable with Community
* Kapplets
* import 
  * sample kapplets
  * user groups
  * roboserver user & password
* LDAP groups?
* Docker secrets
* external storage
* scalable roboservers
* optional log http traffic.
* optional log user actions.
* enable/disable documentation requests

# Phase 3
* Synch
* RFS
* Transformation

# Notes
* PostGres is in 11.2 because we cannot redistribute the MySQL JDBC driver. and Postgres more popular on cloud maybe.
* where are all the roboserver environment variables? docker/Readme.md
* Change Admin password PUT /api/mc/user/resetPassword {"newPassword":"admin","sendEmail":false,"username":"admin","oldPassword":"admin"}
# to do Kofax
* how to get credentials for roboserver user. Add roboserver user to default cluster.
* optionally join Production or Non Production.
* Docker secrets for passwords?

# Ask Benjamin
* get database working for roboserver. The basic docker compose uses derby, but doesn't start it. Is it actually there?
  Docker Secret:  password_file

* how to add groups and users and assign users to roles in projects. SWAGGER can't do it.
* 
* If i preconfigure everything manually - users/groups/. then i have to import them. and how do i then set admin password?
* how to upload robots and types. how to create projects.

# Ask AWS
* Can we have AD or LDAP for users and groups. Open LDAP container.
* how to shutdown modules for enduser - database, rfs, kapplets, synchronizer
* persisting storage for postgres and rfs.
* Is Aurora really so expensive?
* Docker compatible secrets for passwords?
* cheap https.
* scale by CPU.
* scale by webservice.
* can Amazon see inside my containers. where is su's password?
* Are we safe if we don't use SSL between our docker components?

## Roboserver Environment Parameters
Download http://java-decompiler.github.io/ and JDK to view roboserverConfigurator.jar. Read MANIFEST.MF to find the entry point. There you will find **configurationfilesRoboserver.XML**

| property | default | Description |
| -------- | ------- | ----------- |
sec_allow_file_system_access|false|Allow file system access.
sec_allow_connectors|false|Allow connectors to run.
sec_accept_jdbc_drivers|false|Access JDBC drivers sent as part of requests.
sec_log_http_traffic|false|Activate an (audit) log for all HTTP traffic.
enable_socket_service|false|Enable the socket service.
port|50000|Port for the socket service.
enable_ssl_socket_service|false|Enable the SSL socket service.
ssl_port|50001|Port for the SSL socket service.
enable_mc_registration|false|Register with a Management Console.
mc_URL||The URL for the Management Console to register with.
cluster||The cluster to join, when registering with the Management Console.
mc_username||Username to use, when registering with the Management Console.
mc_password||Password to use, when registering with the Management Console.
external_host||The external host name at which the Management Console can reach this server.
external_port|0|The external port at which the Management Console can reach this server.
enable_jms_service|false|enable JMS for communication with the Management Console
broker_url|false|The JMS broker URL
disallow_documentation_requests|false|Blocks RoboServer from handling Documentation Requests.
server_name||The server name used for statistics.

## Robot File System

| property | default | Description |
| -------- | ------- | ----------- |
