# Docker

# to do Kofax
* get database working for roboserver.
* how to get credentials for roboserver user. Add roboserver user to default cluster.
* how to add groups and users and assign users to roles in projects. SWAGGER?
* how to upload robots and types. how to create projects.
* where are all the roboserver environment variables?
* why PostGres?
* install all JDBC drivers.
* optionally join Production or Non Production.
* Docker secrets for passwords?
# to do AWS
* how to shutdown modules for enduser - database, rfs, kapplets, synchronizer
* persisting storage for postgres and rfs.
* Is Aurora really so expensive?
* Docker secrets for passwords?
* cheap https.
* scale by CPU.
* scale by webservice.
* can Amazon see inside my containers. where is su's password?
* Are we safe if we don't use SSL between our docker components?


# Environment Parameters
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
