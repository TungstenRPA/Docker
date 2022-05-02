# provide Amazon Web Services info to access your repository
set asw_account_id=022336740566
set region=eu-central-1
set registry=%asw_account_id%.dkr.ecr.%region%.amazonaws.com


# Docker Quickstart
docker run  --publish 81:80 nginx:1.21.6-alpine


# Download Kofax RPA Linux and go to the folder on the command line
set RPA_version=11.2.0.7
tar -xf d:\iso\rpa\KofaxRPA-%RPA_version%.tar.gz
cd *%RPA_version%*
del *.rpm
del *.deb
git init
git remote add origin git@github.com:KofaxRPA/Docker.git
git fetch
git checkout origin/master -ft




# copy the docker-compose you require
# copy docker\compose-examples\docker-compose-basic.yml docker-compose.yml
docker compose --env-file docker\aws\aws.env -p rpa_%rpa_version% up
docker tag managementconsole:%RPA_version%
docker tag roboserver:%RPA_version%
# login to Amazon Web Services
aws ecr get-login-password --region %region% | docker login --username AWS --password-stdin %registry%
docker tag managementconsole:latest %registry%/console:latest
# push to amazon
docker push %registry%/kofaxrpa:latest
# Tag it with the RPA version
docker push %registry%/kofaxrpa:%RPA_version%

# Configure Docker to communicate directly with Amazon ECS
docker context ls
docker context create ecs Amazon_ECS
# switch docker to Amazon ECS
docker context use Amazon_ECS
# convert docker compose file to Amazon format
docker compose convert
# Start Kofax RPA on Amazon. this costs about $1.50 per day while idle.
docker compose up
# Stop Kofax RPA on Amazon (with loss of ephemeral data)
docker compose down
# View MC and roboserver logs.
docker compose logs
# See Public IP address of Management Console
docker compose ps
# Point Docker back at local machine
docker context default


* Kill All tasks in Powershell  
```cmd
Get-ECSTasks -Cluster $myClusterId | Stop-ECSTask
```
* Kill all tasks in CLI
```cmd
myClusterId="something"
for i in $( aws ecs list-tasks --cluster '$myClusterId --desired-status 'RUNNING' --output text --query 'taskARNS[*]' ) ; do 
    echo aws ecs stop-task --cluster $myClusterId --task $i --reason "Stopped by kill script"
    # aws ecs stop-task --cluster $myClusterId --task $i --reason "Stopped by kill script"
done
```