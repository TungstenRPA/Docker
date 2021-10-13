set RPA_VERSION=11.2.0.2

set AWS_Region=eu-central-1
set AWS_Account=022336740566
set registry=%AWS_Account%.dkr.ecr.%AWS_Region%.amazonaws.com
docker context use default

@REM Docker compose build

docker tag managementconsole:%RPA_VERSION% %registry%/managementconsole:latest
docker tag managementconsole:%RPA_VERSION% %registry%/managementconsole:%RPA_VERSION%
docker tag roboserver:%RPA_VERSION% %registry%/roboserver:latest
docker tag roboserver:%RPA_VERSION% %registry%/roboserver:%RPA_VERSION%

@REM Docker logs into AWS
aws ecr get-login-password --region %AWS_Region% | docker login --username AWS --password-stdin %registry%

@REM Upload Docker images to Amazon Elastic Container Repository
docker push %registry%/managementconsole:latest
docker push %registry%/roboserver:latest

docker context use aws

docker compose --env-file .env --env-file aws\aws.env convert
@REM Deploy Kofax RPA to AWS and start it
docker compose .env --env-file aws\aws.env up 
@REM docker compose down
@REM docker compose logs
@REM this gives the MC URL
docker compose ps