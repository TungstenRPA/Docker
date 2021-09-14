# Download Kofax RPA Linux and go to the folder on the command line
set region = eu-central-1
set amazon = 022336740566.dkr.ecr.eu-central-1.amazonaws.com
set RPA_version = 11.2.0.2
#unzip the installer
tar -xf KofaxRPA-%RPA_version%.tar.gz
# copy the docker-compose you require
copy docker\compose-examples\docker-compose-basic.yml docker-compose.yml
docker compose -p rpa_11.2.0.2 up -d
# login to Amazon Web Services
aws ecr get-login-password --region %region% | docker login --username AWS --password-stdin %amazon%
docker tag managementconsole:latest %amazon%/console:latest
# push to amazon
docker push %amazon%/kofaxrpa:latest
# Tag it with the RPA version
docker push %amazon%/kofaxrpa:%RPA_version%

# Configure Docker to communicate directly with Amazon ECS
docker context ecs Amazon_ECS
# switch docker to Amazon ECS
docker context use Amazon_ECS
# convert docker compose file to Amazon format
docker compose convert
# Start Kofax RPA on Amazon
docker compose up
# View MC and roboserver logs.
docker compose logs
# See Public IP address of Management Console
docker compose ps
# Point Docker back at local machine
docker context default
