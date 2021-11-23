set RPA_VERSION=11.2.0.4

set AWS_Region=eu-central-1
set AWS_Account=022336740566
@REM Find my Enterprise Container Registry for Docker on Amazon
set registry=%AWS_Account%.dkr.ecr.%AWS_Region%.amazonaws.com
@REM Docker logs into AWS
aws ecr get-login-password --region %AWS_Region% | docker login --username AWS --password-stdin %registry%


@REM  is this needed????
aws ecr configure --cluster test --default-launch-type FARGATE --config-name test --region eu-west-1

@REM Create private Repositories in AWS ECR (Elastic Container Registry)
@REM https://docs.aws.amazon.com/cli/latest/reference/ecr/create-repository.html
aws ecr create-repository --repository-name managementconsole
aws ecr create-repository --repository-name /roboserver

docker context create ecs myecscontext



@REM Docker compose build
@REM in aws.env set REGISTRY=
docker context use default
docker compose  --env-file aws\aws.env build
docker tag managementconsole:%RPA_VERSION% %registry%/managementconsole:latest
docker tag managementconsole:%RPA_VERSION% %registry%/managementconsole:%RPA_VERSION%
docker tag roboserver:%RPA_VERSION% %registry%/roboserver:latest
docker tag roboserver:%RPA_VERSION% %registry%/roboserver:%RPA_VERSION%
docker images
docker push %registry%/managementconsole:latest
docker push %registry%/roboserver:latest
docker push %registry%/managementconsole:%RPA_VERSION%
docker push %registry%/roboserver:%RPA_VERSION%
docker context use aws
@REM set %REGISTRY% for amazon
docker compose --env-file aws\aws.env convert
@REM Deploy Kofax RPA to AWS and start it
docker compose  --env-file aws\aws.env up
@REM bring down container
docker compose down
@REM this gives the MC URL
docker compose ps
docker compose logs
