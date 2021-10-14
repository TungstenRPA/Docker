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
* Create a new Docker Context on your computer for *ecs* by typing **docker context create ecs myecscontext**
* Make it the default context by typing **docker context use myecscontext**  
After this Docker Desktop will be working with ECS on AWS and not Docker Desktop.  
* login to ECR (Elastic Container Registry) so that you can get the images from Amazon
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

## Connecting to a shell on a Docker instance in ECS

* [Install](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html) **Session Manager Plugin** for AWS CLI
* download AWS Copilot in an elevated PowerShell session
```powershell
 	Invoke-WebRequest -OutFile 'C:\Program Files\copilot.exe' https://github.com/aws/copilot-cli/releases/latest/download/copilot-windows.exe
```
* set path=%path%;%PROGRAMFILES%\Amazon\SessionManagerPlugin\bin\
* copilot app init

# Configuring HTTPS
## Create Load Balancer
https://techsparx.com/software-development/docker/docker-ecs/load-balancer/https.html  
* Open Amazon Virtual Private Cloud [VPC](https://eu-central-1.console.aws.amazon.com/vpc/home?region=eu-central-1#subnets:)
* Click on **Subnets** and copy your subnets
* Click on **Security/Security Groups** and copy the Security Group ID for **default VPC security group**
* run commandline to create a load balancer.
```
aws elbv2 create-load-balancer --name kofaxrpa --scheme internet-facing --type application --security-groups sg-08ede23deaa1efbfb --subnets subnet-5d96ee76 subnet-34e32369 subnet-8a4dbbf2 subnet-6afbe821
```
* You can see your load balancer under [LoadBalancer](https://eu-central-1.console.aws.amazon.com/ec2/v2/home?region=#LoadBalancers:sort=loadBalancerName) on the [ec2 dashboard](https://eu-central-1.console.aws.amazon.com/ec2/v2/home)
## Set up a Domain Name
* Go to  https://my.freenom.com which can provide a free domain name.
* choose a domain name.
* go to checkout and verify your email address.
* continue on to the next step on Amazon. We need to tell Amazon the address first, and then get the address from Amazon to give the the domain name registrar
## Configure AWS to use your Domain Name
* Go to Amazon's [Route 53 Dashboard](https://console.aws.amazon.com/route53/v2/home#Dashboard) and create a **Public Hosted Zone**
* Click on [Hosted zones](https://console.aws.amazon.com/route53/v2/hostedzones#) and **Create hosted zone**
* Select **public hosted zones** and **create hosted zone**
* go back to [Hosted zones](https://console.aws.amazon.com/route53/v2/hostedzones#) and click on your new domain name to enter its dashboard.
** Create a **new record**. Set the Record name to **mc**. Enable **Alias** and route to **Alias to Application and Classic Load Balancer**/AmazonSubregion/yourloadbalancer
![image](https://user-images.githubusercontent.com/47416964/135839958-e41743c9-7cf7-48b6-a03c-b52042ab9568.png)
* Back in the Records view copy the route URL
![image](https://user-images.githubusercontent.com/47416964/135840512-c3c0a725-fb35-46a1-89d0-59e4c3425c23.png)
* Go back to freenom's [Client Area](https://my.freenom.com/clientarea.php) and manage your domain.
* under *management tools* selecte URL forwarding and add your Amazon URL to the URL forwarding
* Select **Redirect (HTTP 301 forwarding)** as the Forward mode.
## Set up an SSL certificate
* Go to AWS [Certificate Manager](https://eu-central-1.console.aws.amazon.com/acm)
* Click on **Provision certificate**
* Request a **public certificate**
* add your domain name from 
* **Export DNS configuration to a file**
* go to freenom and DNS management. 
* Add all the CNAME entries from the exported DNS config file.
![image](https://user-images.githubusercontent.com/47416964/135901703-c53c6bb4-dc3f-46fe-aae2-23d115343c40.png)
* Wait until your hosting site has published the DNS entries. You will eventually see success in the certificate manager.
![image](https://user-images.githubusercontent.com/47416964/136004663-f6b9f24a-54c8-4fef-b7f2-44a2e64fe9f3.png)



# Cloud Formation Template
needed to put on Amazon Store.

# AWS Cloud Development Kit
https://aws.amazon.com/cdk
Cloud Front distribution network.

VPC= Virtual Private Cloud  - Isolation in AWS Cloud. Up to 5 per region.

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



