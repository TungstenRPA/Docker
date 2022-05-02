# Docker tools for Kofax RPA

"Docker tools" for Kofax RPA allows you to build Docker images for the RoboServer, Management Console, Kapplets, Robotfilesystem, Synchronizer and 
other server components.

## Docker

Using Docker is by far the easiest way to maintain a Kofax RPA setup. Each component supported has a `Dockerfile` prepared that will build a Docker 
image including all the requirements. All you need is to have Docker installed.

### Docker-compose examples

We have added some example `docker-compose` files in the folder `docker/compose-examples` that you can use to get started with a few simple 
configurations.

All examples rely on `PostgreSQL` as the configuration database for Management Console. You can switch the database being used to any of the
databases supported by Kofax RPA. Some databases might require you to add and/or configure the JDBC database drivers needed, as license 
restrictions might prevent us to ship them with the product. 

#### `docker-compose-basic.yml`

Starts a Management Console, a RoboServer a database server and connects them. Before you start this configuration, you might want to enter your 
license information into the docker-compose configuration, to avoid having to type it into Management Console upon startup.

To scale the amount of RoboServers (in the 'Production' cluster) use the command

```
docker-compose -p kapow up -d --scale roboserver-service=2
``` 

#### `docker-compose-rfs.yml`

Like the basic composition, this starts a Management Console, a database server and a RoboServer, but in 
addition it also adds the Robot File System service and configures it.

#### `docker-compose-ha.yml`

This is an example of a high availability setup. It starts a Management Console, a RoboServer, a database server and a load balancer based 
on the lightweight `Traefik` image. The Mangement Console is configured to run with High Availability enabled using multicast discovery 
(requires an enterprise license).  

For this configuration to work optimally, you have to enter your license information into the `docker-compose.yml` file before bringing 
the services up. You also have to edit the line:

```
      - CONFIG_CLUSTER_INTERFACE=172.20.0.*
```

To fit the network assigned to your containers. To find out what network is being used, start docker-compose:

__NOTE: multicast discovery requires a network overlay, that supports UDP multicast.__

```
docker-compose -p name up -d
```

List the containers started:

```
docker container ls
```

And use the command:

```
docker exec kapow_managmentconsole-service_1 hostname -i
```

Stop the composition again, before editing the `docker-compose.yml` file:

```
docker-compose -p kapow down
```

Wildcards can be used, so it could look like. `172.*.*.*` but hazelcast does not accept all wilcards, so `*.*.*.*` is __not__ allowed.

When starting the composition, you can decide to scale the number of running Management Console instances, using the command

```
docker-compose -p kapow up -d --scale managementconsole-service=2
```   

Running more than two instances is possible, but increases the database load. The load balancer is set up to use sticky sessions.

#### `docker-compose-ldap.yml`

An example configuration using LDAP authentication. The LDAP server would normally be provided in the environment you are running the product in.
This example adds an `OpenLDAP` container as a substitute.

We have included a file `ldap_ad_content.ldif` file for your testing pleasure. Test this composition by typing.

```
> docker-compose -p kapow up -d
> docker cp docker/compose-examples/ldap_ad_content.ldif kapow_ldap-service_1:.
> docker exec kapow_ldap-service_1 ldapadd -x -D "cn=admin,dc=example,dc=org" -w admin -f /ldap_ad_content.ldif 
``` 

### `docker-compose-kapplets.yml`

An example featuring a Kapplets server. This is essentially the minimum basic configuration described above, but adds a Kapplets instance. 
All comments from the basic example apply.


## Optimizing the Docker build context size

Since all images are built with the distribution root directory as the build context, this can result in longer build times. 
To optimize the build context size, dockerignore files have been supplied. Since every component has different requirements,
we do not use one global `.dockerignore` file. Instead, we provide one file for every component, that has to be located next 
to the `Dockerfile` and named the same, but with a `.dockerignore` suffix. In our case, they are named `Dockerfile.dockerignore`.

To be able to use this feature, the build via buildkit has to be enabled. The standard Docker build currently only supports 
the global `.dockerignore`. To enable this feature, set `DOCKER_BUILDKIT=1` in the environment, or define it in `/etc/docker/daemon.json`.

If you are building via docker-compose, you also have to set `COMPOSE_DOCKER_CLI_BUILD=1`.

In case you do not build using buildkit, you can rename the `Dockerfile.dockerignore` file to `.dockerignore` and move it into the root of your 
build context. If you build multiple components (like via docker-compose), you will have to combine the `.dockerignore` content. A build using 
buildkit is recommended though, as it is more efficient.


## Try it out

To optimize the build, enabling the build via buildkit is recommended. See the description above.

Copy the basic `docker-compose` file to the root of the untarred binary. 

```
> cp docker/compose-examples/docker-compose-basic.yml docker-compose.yml
```

Then you edit the file to fit it to your own environment, 
and after that start the services by typing.

``` 
> docker-compose -p kapow up -d
```

If this is the first time you build the images, it may take some time to get the images ready.

As soon as docker-compose started the containers, after waiting for the services to start, you 
should be able to navigate to

```
http://localhost:8080
```

And see that a Management Console is running here with a RoboServer in a separate container.

## Setting it up to use your own database

The recommended approach for using Kofax RPA, is to have Management Console configuration and 
repository data in its own containerized database instance, then adding external databases for data storage and (audit-)logs.

However, in some cases you might want to store the Management Console internal configuration data in an external or corporate database, due to 
corporate policies or governance. Also, some database drivers can't be included in public container images due to licensing restrictions.

In case you want to change the database being used, or want to add additional database connections, you can specify additional JDBC drivers 
to be downloaded at runtime. A set of environment variables can be used for this purpose: __JDBC_DRIVER_URL_1__ - __JDBC_DRIVER_URL_9__. The 
environment variable will contain the URL to be used to download the driver to be included. You can specify more then one driver by incrementing 
the numeral at the end. The download process will stop at the first missing or empty environment variable.

To add a MySQL JDBC driver, for instance, you can specify
```
JDBC_DRIVER_URL_1=https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.45/mysql-connector-java-5.1.45.jar
``` 

The environment variable needs to be specified when running the container, as part of the `docker run` command, in the kubernetes deployment or as 
part of the `docker-compose` definition. 

Alternatively, you can replace the default driver supplied with the container by editing the `Dockerfile` for that container and replacing the driver.

In the `Dockerfile` for the Management Console (located `docker/managementconsole/Dockerfile`) the database driver is added by the line

```  
ADD https://jdbc.postgresql.org/download/postgresql-42.2.19.jar /usr/local/tomcat/lib/jdbc/
```

You can change this line or add more drivers. __NOTE: JDBC drivers must be placed in the folder `/usr/local/tomcat/lib/jdbc/`)__
  
After editing a `Dockerfile`, you must rebuild the image by typing

``` 
docker build -f docker/managementconsole/Dockerfile -t managementconsole:11.3.0.0
```

Or simply

``` 
docker-compose -p kapow up -d --build
```

## Backup and restore

The Management Console image contains two scripts for backing up and restoring repository and configuration information.

### `backup.sh`

To create backup to be saved on the location `/kapow/backup` run the following docker command:

```
docker exec <name of the management console container> backup.sh [options]
```

The options are listed below:

```
Usage:

backup.sh [options]

Options:
 -u, --username <username>      The username to use, when calling the Management Console
 -p, --password <password>      The password to use, when calling the Management Console
 -h, --host <hostname>          The hostname for the Management Console (default: localhost)
 -i, --projectId <projectId>    For backing up (only) a specific project
 -c, --configurationOnly Id>    Back-up only the configuration and no project data
 -n, --postfix <postfix>        Set the postfix for the created backup file (default: datetime)
```

### `restore.sh`

To restore a backup saved on the location `/kapow/backup` run the following docker command:

```
docker exec <name of the management console container> restore.sh [options]
```

It can be used like this

```
Usage:

restore.sh [options]

Options:
 -u, --username <username>      The username to use, when calling the Management Console
 -p, --password <password>      The password to use, when calling the Management Console
 -h, --host <host>              The host name for the Management Console (default: localhost)
 -f, --filename <filename>      The name of the backup file to restore
 -a, --path <path>              The path to the backup file to restore (default: /kapow/backup/)
```


## The pre-flight checks

Upon startup Management Console container runs a few pre-flight checks: 

1) It checks that the database configuration seems to work, by connecting to the database using the JDBC URI provided, and will try to run the validation query once.
2) It checks that the LDAP configuration works. If LDAP is configured, each of the LDAP directories will be checked by trying to connect and bind, and running at least a query to retrieve all groups. You can expand this test for debugging / validation purposes by adding a test username to use for more lookups.

If a check fails it will retry for a configurable amount of time. If one of the checks does not succeed within the configured timeout, 
the container will exit. In this case please review your configuration parameters.

You can bypass a check by setting the timeout for the check to 0.

See the environment variables section for more information.

## Data folders

Logs, database data and configuration from the containers are stored in specific folders. If you want to avoid having your container grow, 
these folders should be mounted to a volume or to the local filesystem. Refer to the Docker documentation on volumes.

__NOTE: Logs, database and other data stored on these volumes cannot be reused when upgrading from one version of Kofax RPA to the next.__ 

### RoboServer

Data, logs and configuration from the RoboServer container resides in the folder

```
/kapow/data
```

### ManagementConsole

Tomcat logs reside in the folder

```
/usr/local/tomcat/logs
```

Backups are saved and restored to the folder

```
/kapow/backup
```

## Environment variables for the RoboServer container

### `WRAPPER_MAX_MEMORY`  (default: )
The java heap size (in MB)
### `WRAPPER_JAVA_ADDITIONAL_1`  (default: )
Additional java parameter 1
### `WRAPPER_JAVA_ADDITIONAL_2`  (default: )
Additional java parameter 2
### `WRAPPER_JAVA_ADDITIONAL_3`  (default: )
Additional java parameter 3
### `WRAPPER_JAVA_ADDITIONAL_4`  (default: )
Additional java parameter 4
### `ROBOSERVER_SEC_ALLOW_FILE_SYSTEM_ACCESS`  (default: false)
Allow file system access.
### `ROBOSERVER_SEC_ACCEPT_JDBC_DRIVERS`  (default: false)
Access JDBC drivers sent as part of requests.
### `ROBOSERVER_SEC_LOG_HTTP_TRAFFIC`  (default: false)
Activate an (audit) log for all HTTP traffic.
### `ROBOSERVER_ENABLE_SOCKET_SERVICE`  (default: false)
Enable the socket service.
### `ROBOSERVER_SOCKET_SERVICE_PORT`  (default: 50000)
Port for the socket service.
### `ROBOSERVER_ENABLE_SSL_SOCKET_SERVICE`  (default: false)
Enable the SSL socket service.
### `ROBOSERVER_SOCKET_SSL_SERVICE_PORT`  (default: 50001)
Port for the SSL socket service.
### `ROBOSERVER_ENABLE_MC_REGISTRATION`  (default: false)
Register with a Management Console.
### `ROBOSERVER_MC_URL`  (default: )
The URL for the Management Console to register with.
### `ROBOSERVER_MC_CLUSTER`  (default: )
The cluster to join, when registering with the Management Console.
### `ROBOSERVER_MC_USERNAME`  (default: )
Username to use, when registering with the Management Console.
### `ROBOSERVER_MC_PASSWORD`  (default: )
Password to use, when registering with the Management Console.
### `ROBOSERVER_EXTERNAL_HOST`  (default: )
The external host name at which the Management Console can reach this server.
### `ROBOSERVER_EXTERNAL_PORT`  (default: 0)
The external port at which the Management Console can reach this server.
### `ROBOSERVER_SERVER_NAME` (default: )
The name of the server used to track statistics.
### `LOG4J_ROOTLOGGER`  (default: ERROR, file)
root logging level
### `LOG4J_LOGGER_WEBKIT`  (default: INFO)
log-level for messages related to WebKit
### `LOG4J_LOGGER_KAPOW_SERVERMESSAGELOG`  (default: INFO)
log-level for log messages not related to a robot
### `LOG4J_LOGGER_KAPOW_ROBOTRUNLOG`  (default: INFO)
log-level for log messages related to robot runs
### `LOG4J_LOGGER_KAPOW_ROBOTMESSAGELOG`  (default: INFO)
log-level for log messages logged by a robot
### `LOG4J_LOGGER_KAPOW_AUDITLOG`  (default: OFF)
log-level for messages with each http/ftp request
### `LOG4J_LOGGER_KAPOW_KCUMANAGER_KCUINFO`  (default: OFF)
log-level for KCU information
### `LOG4J_LOGGER_HUB`  (default: WARN, file)
log level related to the desktop automation process
### `LOG4J_APPENDER_FILE_MAXFILESIZE`  (default: 10MB)
max log file size for the log, before it rotates
### `LOG4J_APPENDER_FILE`  (default: /kapow/data/Logs/${logFileName})
path and log file name
### `LOG4J_APPENDER_FILE_MAXBACKUPINDEX`  (default: 3)
max number of rotated logs

## Environment variables for the ManagementConsole container

### `TOMCAT_WEB_HSTSENABLE`  (default: false)
Enables HTTP Strict Transport Security (HSTS) that encourages browsers to require HTTPS and certain other restrictions. Enable this option to enforce tighter security.
### `CONTEXT_RESOURCE_MAXTOTAL`  (default: 100)
Maximum number of database connections in pool. Make sure to configure your database to handle (at least) as many connections as you define here.
### `CONTEXT_RESOURCE_MAXIDLE`  (default: 30)
Maximum number of idle database connections to retain in pool. Set to -1 for no limit. See also the DBCP documentation about this.
### `CONTEXT_RESOURCE_MAXWAITMILLIS`  (default: -1)
Maximum time to wait for a database connection to become available in ms. An Exception is thrown if this time-out is exceeded. Set to -1 to wait indefinitely.
### `CONTEXT_RESOURCE_VALIDATIONQUERY`  (default: SELECT 1)
validation query to use, when taking out a connection from the pool
### `CONTEXT_RESOURCE_TESTONBORROW`  (default: true)
set to true to validate connections when taking them out of the pool
### `CONTEXT_RESOURCE_USERNAME`  (default: )
The user name for the database.
### `CONTEXT_RESOURCE_PASSWORD`  (default: )
The password for the database.
### `CONTEXT_RESOURCE_PASSWORD_FILE`  (default: )
The path to a file containing the password for the database, could e.g. be a docker secret.
### `CONTEXT_RESOURCE_DRIVERCLASSNAME` __REQUIRED__ (default: )
The JDBC driver class name (has to be a javax.sql.DataSource).
### `CONTEXT_RESOURCE_URL` __REQUIRED__ (default: )
the database JDBC URL
### `CONTEXT_JARSCAN_DEFAULT`  (default: false)
The default behavior to scan jar files for TLDs.
### `CONTEXT_JARSCAN_JARS`  (default: log4j-web*.jar,log4j-taglib*.jar,log4javascript*.jar,slf4j-taglib*.jar,spring-webmvc-*.jar,taglibs-standard-impl-*.jar,taglibs-standard-jstlel-*.jar)
The list of jar files to scan for TLDs (patterns allowed).
### `CONTEXT_CHECK_DATABASE_TIMEOUT`  (default: 120)
database connection pre-flight check time-out - set to 0 if the pre-flight check should not run.
### `CONFIG_LICENSE_NAME`  (default: )
the name associated with your license
### `CONFIG_LICENSE_EMAIL`  (default: )
the email associated with your license.
### `CONFIG_LICENSE_COMPANY`  (default: )
the company name matching your license.
### `CONFIG_LICENSE_PRODUCTIONKEY`  (default: )
Your license production key.
### `CONFIG_LICENSE_NONPRODUCTIONKEY`  (default: )
Your license non-production key.
### `CONFIG_CLUSTER_PORT`  (default: 5701)
The TCP port to listen for connections, when running in clustered mode.
### `CONFIG_CLUSTER_INTERFACE`  (default: 127.0.0.1)
Interface to bind to for listening to cluster connections. Using local interface will not work for docker containers. You can use wildcards here, like 192.*.*.* - but it will not accept 0.0.0.0
### `CONFIG_CLUSTER_JOINCONFIG`  (default: noCluster)
Set to either 'tcpCluster' or 'multicastCluster' for node discovery. Both require settings. 'multicastCluster' is by far the most flexible, but requires a network overlay that can handle UDP/multicast.
### `CONFIG_CLUSTER_TCP_NODE_COUNT`  (default: 0)
The number of nodes in the TCP cluster.
### `CONFIG_CLUSTER_TCP_NODE_HOST_<N>`  (default: )
The host-name or ip-number of of a node in the TCP cluster.
### `CONFIG_CLUSTER_TCP_NODE_PORT_<N>`  (default: 5701)
The the port for that host name.
### `CONFIG_CLUSTER_MULTICAST_GROUP`  (default: 224.2.2.3)
The multicast group to use for multicast discovery of nodes.
### `CONFIG_CLUSTER_MULTICAST_PORT`  (default: 54327)
The port to send the multicast messages for.
### `CONFIG_KEYSTORE_LOCATION`  (default: /WEB-INF/mc.p12)
Path to the location of the keystore file. The default value points to the keystore distributed with the Management Console. It is strongly recommended to generate a new private key and place it in the container. (e.g. by using a docker secret or by mounting a volume).
### `CONFIG_KEYSTORE_PASSWORD`  (default: changeit)
Pass phrase for the key store
### `CONFIG_KEYSTORE_PASSWORD_FILE`  (default: )
The path to a file containing the pass phrase for the key store.
### `CONFIG_KEYSTORE_ALIAS`  (default: mc)
The alias for the key store
### `CONFIG_SECURITY_ALLOWSCRIPTEXECUTION`  (default: false)
Allow script execution.
### `CONFIG_SECURITY_JDBCDRIVERUPLOAD`  (default: LOCALHOST)
Allow JDBC driver uploads to the ManagementConsole. Can be set to NONE, LOCALHOST, ANY_HOST.
### `CONFIG_PASSWORDSTORE`  (default: STANDARD)
Selects password store type.
### `SETTINGS_ENTRY_COUNT`  (default: 0)
Use this variable to indicate how many defaults you want to override.
### `SETTINGS_ENTRY_KEY_<N>` __REQUIRED__ (default: )
The name of the default setting to override.
### `SETTINGS_ENTRY_VALUE_<N>` __REQUIRED__ (default: )
The value to set as new default value.
### `SETTINGS_CLUSTER_COUNT`  (default: 0)
Adding one or more entries here will override cluster(s) that are normally created per default upon boot
### `SETTINGS_CLUSTER_NAME_<N>` __REQUIRED__ (default: )
The name of the cluster to create
### `SETTINGS_CLUSTER_LICENSEUNITS_<N>`  (default: 0)
The number of license units (KCU or CRE) to assign to the cluster. 0 = automatic
### `SETTINGS_CLUSTER_PRODUCTION_<N>`  (default: true)
Set to false if this is a non-production cluster
### `SETTINGS_CLUSTER_HYBRID_<N>`  (default: false)
Set to true if this is a hybrid cluster (see documentation).
### `SETTINGS_CLUSTER_SSL_<N>`  (default: false)
Set to true if this cluster is an ssl cluster.
### `SETTINGS_CLUSTER_DYNAMIC_LICENSE_<N>`  (default: false)
Set to true if this cluster uses dynamic license distribution.
### `SETTINGS_CLUSTER_THRESHOLD_VERSION_<N>`  (default: )
Set to the threshold RoboServer version for this cluster, leave empty to set to current version.
### `SETTINGS_CLUSTER_PROXY_COUNT_<N>`  (default: 0)
The number of proxies to add to this cluster
### `SETTINGS_CLUSTER_PROXY_HOST_<N>_<N>` __REQUIRED__ (default: )
The hostname of the proxy
### `SETTINGS_CLUSTER_PROXY_PORT_<N>_<N>` __REQUIRED__ (default: )
The port number of the proxy service
### `SETTINGS_CLUSTER_PROXY_USERNAME_<N>_<N>`  (default: )
The user name to use for authentication with the proxy service.
### `SETTINGS_CLUSTER_PROXY_PASSWORD_<N>_<N>`  (default: )
The password to use for authentication with the proxy service (use the file variant to keep the password secret).
### `SETTINGS_CLUSTER_PROXY_PASSWORD_FILE_<N>_<N>`  (default: )
The path to a file containing the password to use for authentication with the proxy service.
### `SETTINGS_CLUSTER_PROXY_EXCLUDEDHOSTS_<N>_<N>`  (default: localhost,127.0.0.1)
A comma separated list of host names or wild-cards to exclude from the proxy.
### `SETTINGS_CYBERARK_URL`  (default: )
CyberArk Central Credentials Provider host's URL.
### `SETTINGS_CYBERARK_PORT`  (default: )
CyberArk Central Credentials Provider host's port.
### `SETTINGS_CYBERARK_IISAPPLICATIONNAME`  (default: )
CyberArk Central Credentials Provider IIS application name.
### `SETTINGS_CYBERARK_CERTIFICATEPATH`  (default: )
CyberArk Central Credentials Provider TLS server certificate.
### `SERVICE_OAUTH_KAPPLETS_SECRET`  (default: )
Initial Kapplets client secret in plaintext
### `SERVICE_OAUTH_KAPPLETS_SECRET_FILE`  (default: )
Path to file containing initial Kapplets client secret
### `SAML_LOGGER_LOGALL`  (default: false)
Log all SAML messages.
### `SAML_LOGGER_LOGERRORS`  (default: false)
Log all SAML errors.
### `SAML_LOGGER_LOGEXCEPTIONS`  (default: false)
Log all SAML exceptions.
### `SAML_SP_ENTITYID`  (default: )
SAML SP Entity ID
### `SAML_SP_REQUESTSIGNED`  (default: false)
Request signed... (MORE DOCS)
### `SAML_SP_ENTITYBASEURL`  (default: )
SAML SP Base URL
### `SAML_HTTP_IDP_COUNT`  (default: 0)
The number of HTTP based IDP metadata providers to add.
### `SAML_HTTP_IDP_URL_<N>`  (default: )
The URL for the metadata
### `SAML_IDP_GROUP_ATTRIBUTE_COUNT`  (default: 0)
The number of attributes containing group memberships
### `SAML_IDP_GROUP_ATTRIBUTE_<N>`  (default: 0)
Group attribute
### `SAML_IDP_USERNAME_ATTRIBUTE`  (default: true)
Enable to configure custom filed for user name mapping
### `SAML_IDP_USERNAME_VALUE`  (default: email)
Configure custom filed for user name mapping
### `SAML_IDP_USESINGLELOGOUT`  (default: false)
Enable to use SAML Single Logout
### `LOGIN_USE_LDAP`  (default: false)
Use LDAP for authentication, after enabling this, there must be at least one LDAP directory configured.
### `LOGIN_USE_SAML`  (default: false)
Use SAML2.0 for authentication. Further configuration is needed.
### `LOGIN_CREATE_ADMIN_USER`  (default: false)
Create an admin user in the user database, regardless of authentication method
### `LOGIN_USE_SITEMINDER`  (default: false)
Enable Siteminder (pre-)authentication.
### `LOGIN_SITEMINDER_HEADER`  (default: sm_userdn)
The header set by Siteminder that contains the user DN.
### `LOGIN_SITEMINDER_ACCOUNT_ATTRIBUTE`  (default: sAMAccountName)
The account attribute to use for Siteminder, default works with Windows AD.
### `LOGIN_SITEMINDER_ACCOUNT_ATTRIBUTE_PATTERN`  (default: (.*))
The account attribute pattern to use for Siteminder, default works with Windows AD.
### `LOGIN_LDAP_DIRECTORY_COUNT`  (default: 0)
The number of LDAP directories to add into the configuration.
### `LOGIN_LDAP_DIRECTORY_ADMINGROUP_COUNT_<N>`  (default: 1)
The number of groups in the list of administrator groups.
### `LOGIN_LDAP_DIRECTORY_ADMINGROUP_VALUE_<N>_<N>`  (default: ADMINISTRATOR)
The name of an administrator group.
### `LOGIN_LDAP_DIRECTORY_ADMINISTRATORGROUP_COUNT_<N>`  (default: 1)
The number of groups in the list of rpa administrator groups.
### `LOGIN_LDAP_DIRECTORY_ADMINISTRATORGROUP_VALUE_<N>_<N>`  (default: RPAADMINISTRATOR)
The name of an rpa administrator group.
### `LOGIN_LDAP_DIRECTORY_SERVERURL_<N>`  (default: )
The URL for the LDAP directory.
### `LOGIN_LDAP_DIRECTORY_USERDN_<N>`  (default: )
The bind user DN.
### `LOGIN_LDAP_DIRECTORY_PASSWORD_<N>`  (default: )
The bind password.
### `LOGIN_LDAP_DIRECTORY_PASSWORD_FILE_<N>`  (default: )
The path to a file containing the bind password.
### `LOGIN_LDAP_DIRECTORY_USERSEARCHBASE_<N>`  (default: )
The base to search for users.
### `LOGIN_LDAP_DIRECTORY_USERSEARCHFILTER_<N>`  (default: )
The filter to apply, combined with the login to apply while searching.
### `LOGIN_LDAP_DIRECTORY_USERSEARCHSUBTREE_<N>`  (default: true)
Search the subtree from the base to look for the user.
### `LOGIN_LDAP_DIRECTORY_GROUPSEARCHBASE_<N>`  (default: )
The base to use, when searching for groups.
### `LOGIN_LDAP_DIRECTORY_GROUPSEARCHFILTER_<N>`  (default: (member={0}))
The filter to apply, combined with the user DN to search for group memberships.
### `LOGIN_LDAP_DIRECTORY_GROUPROLEATTRIBUTE_<N>`  (default: cn)
The group role attribute.
### `LOGIN_LDAP_DIRECTORY_GROUPSEARCHSUBTREE_<N>`  (default: true)
Search the subtree when looking for groups.
### `LOGIN_LDAP_DIRECTORY_ALLGROUPSFILTER_<N>`  (default: (cn=*))
Filter to apply when listing all groups.
### `LOGIN_LDAP_DIRECTORY_FULLNAMEATTRIBUTE_<N>`  (default: displayName)
The full-name attribute to use for users.
### `LOGIN_LDAP_DIRECTORY_EMAILATTRIBUTE_<N>`  (default: userPrincipalName)
The attribute to use to retrieve a users email.
### `LOGIN_LDAP_DIRECTORY_REFERRAL_<N>`  (default: follow)
Follow referrals, sometimes useful in when forests use several ADs for subdomains.
### `LOGIN_LDAP_DIRECTORY_CONVERTTOUPPERCASE_<N>`  (default: true)
Convert group names to upper-case.
### `LOGIN_LDAP_CHECK_TIMEOUT_<N>`  (default: 120)
LDAP pre-flight check time-out, set to 0 to disable this check.
### `LOGIN_LDAP_CHECK_TESTUSER_<N>`  (default: )
A user name that can be found in the LDAP directory to search for and while running the pre-flight check.
### `TOMCAT_SERVER_SESSION_REPLICATION`  (default: false)
Enable session replication between tomcat instances, should only be needed if load balancer does not support sticky sessions, and will only work if the network overlay supports multicast
### `TOMCAT_SERVER_CONNECTOR_URIENCODING`  (default: UTF-8)
The encoding for URIs
### `TOMCAT_SERVER_CONNECTOR_MAXPOSTSIZE`  (default: 2097152)
The maximum size in bytes of the POST which will be handled by the container FORM URL parameter parsing. The limit can be disabled by setting this attribute to a value less than zero. If not specified, this attribute is set to 2097152 (2 megabytes)
### `TOMCAT_SERVER_SSL_CONNECTOR`  (default: false)
Set to true to enable SSL
### `TOMCAT_SERVER_SSL_CONNECTOR_PORT_<N>`  (default: 8443)
The https port
### `TOMCAT_SERVER_SSL_CONNECTOR_MAXTHREADS_<N>`  (default: 150)
max threads for this connector, default should be adequate
### `TOMCAT_SERVER_SSL_CONNECTOR_URIENCODING_<N>`  (default: UTF-8)
The encoding for URIs in the SSL connector
### `TOMCAT_SERVER_SSL_CONNECTOR_CERTIFICATEKEYFILE_<N>_<N>_<N>`  (default: )
path to the certificate key file
### `TOMCAT_SERVER_SSL_CONNECTOR_CERTIFICATEFILE_<N>_<N>_<N>`  (default: )
path to the certificate file
### `TOMCAT_SERVER_SSL_CONNECTOR_CERTIFICATECHAINFILE_<N>_<N>_<N>`  (default: )
path to the certificate chain file
### `PERSISTENCE_PU1_LOG_LEVEL`  (default: SEVERE)
For debugging of the (eclipse) persistence layer, you can change this value to e.g. FINE for detailed log information
### `LOG4J_LOGGER_COM_HAZELCAST`  (default: ERROR)
log-level for log messages related to Hazelcast / high availability
### `LOG4J_LOGGER_ORG_APACHE`  (default: ERROR)
log-level for log messages related to Apache / Tomcat
### `LOG4J_LOGGER_ORG_QUARTZ`  (default: ERROR)
log-level for log messages related to Quartz / Scheduler
### `LOG4J_LOGGER_SERVICE_DISTRIBUTION`  (default: ERROR)
log-level for log messages related to clustered distribution
### `LOG4J_LOGGER_SERVICE_LOGGING`  (default: ERROR)
log-level for log messages related to log database
### `LOG4J_LOGGER_ADDITIONAL_COUNT`  (default: 0)
The number of additional properties to add to the log4j.properties file.

Warning: The syntax of the log4j configuration changed since log4j2 is now used. 
Please check the log4j2.properties syntax and specify your parameters accordingly.

### `LOG4J_LOGGER_ADDITIONAL_KEY_<N>`  (default: )
The key of the addition property NN
### `LOG4J_LOGGER_ADDITIONAL_VALUE_<N>`  (default: )
The value of the addition property NN

### Special settings for the `SETTINGS_ENTRY_KEY` names

#### `USE_LOGDB`
Enable or disable log database

#### `LOGDB_SCHEMA`
The name of the schema / database to use for the log database

#### `LOGDB_HOST`
The name of the host for the log database

#### `LOGDB_TYPE`
The name of the type of database that runs the log database, refer to the list of types in Management Console

#### `LOGDB_USERNAME`
The username for the log database

#### `LOGDB_PASSWORD`
The password to use for the log database

#### `USE_ANALYTICS_DATABASE`
Enable or disable analytics database

#### `ANALYTICS_DATABASE_SCHEMA`
The name of the schema / database to use for analytics database

#### `ANALYTICS_DATABASE_HOST`
The name of the host for the analytics database

#### `ANALYTICS_DATABASE_TYPE`
The name of the type of database that runs the analytics database, refer to the list of types in Management Console

#### `ANALYTICS_DATABASE_USERNAME`
The username for the analytics database

#### `ANALYTICS_DATABASE_PASSWORD`
The password for the analytics database

## Environment variables for the Robot File System container

### `RFS_MC_URL`  (default: )
The base URI for the Management Console
### `RFS_MC_USERNAME`  (default: )
User name for connect to the Management Console
### `RFS_MC_PASSWORD`  (default: )
Passwords for connecting to the Management Console
### `RFS_MC_PASSWORD_FILE`  (default: )
The path to a file containing the password for the Management Console, this could be a docker secret.
### `RFS_DATA_PATH`  (default: )
The root path for the local data storage
### `RFS_ALLOW_ABSOLUTE_PATHS`  (default: )
Allow the sharing of folders outside of the root data path
### `RFS_CREATE_FOLDERS`  (default: )
Create folders for shares stored locally or require the folders to be available

## Environment variables for the Synchronizer

### `SYNCHRONIZER_MC_URL`
URL to connect to the Management Console, containing the protocol and a port number.
### `SYNCHRONIZER_USERNAME`
Management Console user
### `SYNCHRONIZER_PASSWORD`
Password for the Management Console user
### `SYNCHRONIZER_INTERVAL`
Interval in seconds between synchronization runs. If set to a value equal to or less than 0 or not a numeric value, the Synchronizer runs once and exits.
### `SYNCHRONIZER_PRIVATE_KEY`
Path to a file containing the private SSH key to connect to a remote repository. 
When connecting to a local repository, this attribute is ignored, but any value must be
specified.
### `SYNCHRONIZER_NO_HOST_KEY`
Disable strict SSH host-key checking

### Build Synchronizer image

To build Synchronizer Docker image use following command:

```
docker build -f docker/synchronizer/Dockerfile -t synchronizer:11.3.0.0
```

NOTE: If you want to disable Docker JMX health check remove lines in `Dockerfile` between:

```
# ### start cutting here ###
```
and
```
# ### end cutting here ###
```
