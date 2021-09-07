# Docker

# Create Docker Image
1. Download Docker Desktop.
2. Download Linux for Windows inside Docker.
3. Download Linux RPA.
4. Unzip RPA linux with **tar -xf KofaxRPA-11.2.0.2.tar.gz**
5. CD to unzip directory
6. **copy docker\compose-examples\docker-compose-basic.yml docker-compose.yml**
7. View Docker File in Visual Studio Code with **code docker\managementconsole\Dockerfile**
8. Create Docker Image with **docker-compose -p RPA_Partner up -d**.   "up" means to start it, and "-d" means to detatch it from the console to get the cursor back.

# Add Docker Image to Amazon Repository
1. Download [https://aws.amazon.com/cli/](Amazon%20Web%20Services%20Command%20Line%20Interface)
2. Login to [https://aws.amazon.com/](Amazon%20Webservices)
3. 

# to do Kofax
* how to get credentials for roboserver user. Add roboserver user to default cluster.
* optionally join Production or Non Production.
* Docker secrets for passwords?

# Ask Benjamin
* why PostGres in 11.2?
* how to add groups and users and assign users to roles in projects. SWAGGER can't do it.
* If i preconfigure everything manually - users/groups/. then i have to import them. and how do i then set admin password?
* get database working for roboserver. The basic docker compose uses derby, but doesn't start it. Is it actually there?
* How do I set the logging database settings?
* how to upload robots and types. how to create projects.
* where are all the roboserver environment variables?
* install all JDBC drivers.

# Ask AWS
* how to shutdown modules for enduser - database, rfs, kapplets, synchronizer
* persisting storage for postgres and rfs.
* Is Aurora really so expensive?
* Docker secrets for passwords?
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
