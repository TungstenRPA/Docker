# Kofax RPA on Amazon Web Services with Docker
How to get Kofax RPA running on Amazon Web Services for about 5 cents/hour while robots are running.  

# Download and Install Software
1. Download [Docker Desktop](https://www.docker.com/products/docker-desktop).
2. Download the [Linux kernal update package](https://docs.microsoft.com/en-us/windows/wsl/install-win10#step-4---download-the-linux-kernel-update-package) from Microsoft.
3. Download the [Linux version of Kofax RPA]([https://delivery.kofax.com]).
4. Unzip RPA Linux with **tar -xf KofaxRPA-11.2.0.2.tar.gz**
5. CD to unzip directory

*The next two sections (creating and uploading) can be skipped by downloading the preconfigured Docker Compose files for Amazon Webservices from [Kofax RPA on GitHub](https://github.com/KofaxRPA/Docker/tree/RPA-11.2.0.2)*  

# Create Docker Image
6. **copy docker\compose-examples\docker-compose-basic.yml docker-compose.yml** 
7. View Docker File in Visual Studio Code with **code docker\managementconsole\Dockerfile**
8. Create Docker Image with **docker compose -p rpa_11.2.0.2 up -d**.   
  * "-p" project name (default is directory name)
  * "up" create and dostart it
  * "-d" means to detatch it from the console to get the cursor back.

# Uploading Docker Image to Amazon Repository
1. Download [https://aws.amazon.com/cli/](Amazon%20Web%20Services%20Command%20Line%20Interface)
2. Login to [https://aws.amazon.com/](Amazon%20Webservices)
3. Select your region. I chose **eu-central-1** in Frankfurt.
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

# Deploy containerized RPA on AWS Fargate using Docker & Docker Compose
[https://www.docker.com/blog/docker-compose-from-local-to-amazon-ecs/]
With [AWS Fargate](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html), you don't have to manage servers or clusters to run containerized applications. You don't care about server types - all you need to think about is CPU strength and RAM. For learning Kofax RPA and deploing robots Fargate is adquate. ECS charges for machines, and Fargate charges per usage. Fargate costs only 2-3$/month for running occasional robots.  
## Create a Docker Context for AWS
Docker Desktop has a **default** context on the local machine. See it by typing **docker context ls**.  
![image](https://user-images.githubusercontent.com/47416964/133095222-911b038f-1fc3-4c8a-8c6e-ccd3dc09fae8.png)
* Create a new Docker Context on your computer for *ecs* by typing **docker context ecs myecscontext**
* Make it the default context by typing **docker context use myecscontext**  
After this Docker Desktop will be working with ECS on AWS and not Docker Desktop.  
* Type **docker compose convert** to build Kofax RPA.
* Type **docker compose up** to deploy Kofax RPA to AWS.
* Type **docker compose down** to stop Kofax RPA on AWS.
* Type **docker compose logs** to see Management Console and Roboserver Logs. MC take about 5 minutes to start up and then Roboserver a few minutes.
* Type **docker compose ps** to find the URL of the Management Console.  
![image](https://user-images.githubusercontent.com/47416964/133255630-5a93c43b-bbf2-4795-8049-30ab0f1eefb8.png)

## Viewing your Cluster in Amazon Elastic Container Service (ECS)
ECS is Amazon's container orchestration system, like Kubernetes.  
* Open https://console.aws.amazon.com/ecs and make sure your region is selected.
* Click **Clusters** to see your cluster. There are 3 services and 3 tasks corresponding to the 3 Containers: Postgres Database, Management Console and Roboserver).
* Click on the **Task Definition** of the Management Console and scroll down and you will see how much RAM and CPU has been allocated to it.  
![image](https://user-images.githubusercontent.com/47416964/133256234-ea3bc6cf-4362-4321-926e-af64fc20c9e4.png)

# Tweaking, Config
[Add HTTPS to Load Balancer](https://docs.docker.com/cloud/ecs-integration/#setting-ssl-termination-by-load-balancer)  *currently not working...*  
[Service Discovery](https://docs.docker.com/cloud/ecs-integration/#service-discovery) configures how machines inside the cluster see each other. This is not needed as the Roboserver is able to find the Management Console using http://managementconsole-service:8080/ within the Cluster.

# Pricing Calculator
[Cost Explorer](https://console.aws.amazon.com/cost-management) - [Fargate Pricing](https://aws.amazon.com/fargate/pricing/) -
[Price Calculator](https://calculator.aws/#/createCalculator/Fargate)
* Select region (I chose **Europe (Frankfurt)**)
* **3 tasks per month** (For Database, Management Console and Roboserver)
* **duration = 730 hours**
* **0.25** CPU and **1 GB** .See **Supported Configurations** at [Fargate Pricing](https://aws.amazon.com/fargate/pricing/)
* **20 GB of ephemeral storage**  *The first 20GB are free**
This gives about 0.05 USD / hour, which is about 37$/Month for 24/7 robot running.

# POC - done
* [x] Upload Management Console and Roboserver to Amazon's container Repository
* [x] Postgres Database in an ephemeral container, MC & Roboserver
* [x] Default to **Non Production** Cluster
* [x] Deploy database + MC + Roboserver to Cloud.

# Phase 1 - Internal
* [x] Add to Amazon Repository
* [x] Roboserver logging to Postgres database. (by default it logs to "Development Database" which is not even running)
* [x] Create groups **Developers**, **Roboservers**, **Kapplet Users**, **Project Admininstrators**, **Kapplet Administrators**
* [x] run configure script in second thread from managementconsole.sh
* [x] restore MC from backup for users, groups, project roles, cluster database
* [x] Make roboserver wait until it can log in before starting the roboserver. 
* [x] Get **NewsMagazine.robot** log to MC log database.
* [x] Get **NewsMagazine.robot** to  write data to MC's postgres database.
* [x] make **NewsMagazine.robot** create object table in Postgres.
* [ ] Changes to Backup
  * [ ] Non-Production cluster uses **scheduler** database for data.
  * [ ] MC/Settings/DesignStudio/DatabasesToSendToDesignStudio=false
  * [ ] no robot dev nor roboserver user (both added later)
  * [ ] Load **NewsMagazine.robot**, which writes to MC data database and usable in Kapplets
* [ ] make sure roboserver waits until MC restore is finished before connecting to cluster. beware roboserver fails to connect to MC after 3rd attempt, so use curl to see that MC is ready.
* [x] create personal user and add to the Kapplet Users, developers and Admin groups. 
* [ ] Change Admin password 
* [ ] ensure roboserver runs with new password
* [ ] set default data database to postgres and not objectdb. (maybe stick logs there as well)
* [ ] Add to Amazon Market Place
* [ ] Add HTTPS
* [ ] Scale roboservers by CPU %.
* [ ] Deploy with Wizard from Amazon Marketplace.  
* [ ] Upload postgres driver to MC (it goes to Postgres table mc_jar_file) http://localhost:8080/api/mc/setting/Database/Drivers/add  Do i really need this?  
Accept-Encoding: gzip, deflate 
```
Content-Disposition: form-data; name="file"; filename="postgresql-42.2.19.jar"
Content-Type: application/octet-stream
```
* [ ] Make sure that Design Studio can download Postgres JDBC driver from MC.  
![](img/2021-09-29-15-25-02.png)
## BLOCKING
* Roboserver won't connect if failed to login twice. with Benjamin  
*workaround: wait for MC to restore backup before launching roboserver, by curling if roboserver user can log in*

# Phase 2 - Sharable with Community
* [ ] Check the [Amazon Aurora Postgres](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.AuroraPostgreSQL.html) is actually compatible with Kofax RPA. (i created a Free Tier, lowest level 20GB which is 0.019c/hour in Frankfurt. Serverless seems to be in beta...)
* optimize CPU and RAM for MC & Roboserver
* Kapplets
* import 
  * sample kapplets
  * user groups
  * roboserver user & password
* scalable roboservers
* optional log http traffic.
* optional log user actions.
* enable/disable documentation requests

# Phase 3
* Git Synchronizer
* Amazon Aurora database support for persistence.
* Support external storage for database .
* RFS
* Kofax Transformation (not compatible with FarSight. Need ECS)
* Make rfs, kapplets, synchronizer optional

# Phase 4
* Kubernetes
* Docker secrets
* AD or LDAP for users and groups. Maybe with an Open LDAP container.
* VPN/tunnel for backoffice DTS.

# Notes
* PostGres is in 11.2 because we cannot redistribute the MySQL JDBC driver. and Postgres more popular on cloud maybe.
* where are all the roboserver environment variables? docker/Readme.md

# Ask AWS
* how to shutdown modules for enduser - database, rfs, kapplets, synchronizer

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
