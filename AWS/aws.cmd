set RPA_VERSION=11.2.0.2

set AWS_Region=eu-central-1
set AWS_Account=022336740566
set registry=%AWS_Account%.dkr.ecr.%AWS_Region%.amazonaws.com
docker context use default

#docker compose build

docker tag managementconsole:%RPA_VERSION% %registry%/managementconsole:latest
docker tag roboserver:%RPA_VERSION% %registry%/roboserver:latest

aws ecr get-login-password --region %AWS_Region% | docker login --username AWS --password-stdin %registry%

docker push %registry%/managementconsole:latest
docker push %registry%/roboserver:latest

docker context use aws

docker compose convert
# Deploy Kofax RPA to AWS and start it
docker compose up 
#docker compose down
#docker compose logs
#this gives the MC URL
docker compose ps