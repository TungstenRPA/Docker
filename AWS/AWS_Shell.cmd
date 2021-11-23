@rem https://aws.amazon.com/blogs/containers/new-using-amazon-ecs-exec-access-your-containers-fargate-ec2/
@REM download https://github.com/stedolan/jq/releases/download/jq-1.6/jq-win64.exe
@rem set CONTAINER_NAME=nginc
set DEMO_NAME=RPA
aws ecs list-clusters
@set CLUSTER_NAME=%DEMO_NAME%-cluster
set cluster_name=docker



@REM get the vpc=Virtual Private Cloud
FOR /F "tokens=*" %%g IN ('aws ec2 describe-vpcs --query Vpcs[].VpcId --output text') do (SET VPC_ID=%%g)
aws ec2 describe-subnets --filters "Name=vpc-id,Values=%VPC_ID%
@REM vpc-05c65294412c0a29f
@REM subnet-0618b69e1e72ba159,
@REM subnet-08950d7e44aca34e5,
@REM subnet-0ddc59f3538e272ff

@REM KMS=Key Management System
set PUBLIC_SUBNET1=subnet-0618b69e1e72ba159
set PUBLIC_SUBNET2=subnet-08950d7e44aca34e5
set PUBLIC_SUBNET3=subnet-0ddc59f3538e272ff
aws kms create-key --region %AWS_REGION% > KMS.key
aws kms create-key --region %AWS_REGION% |findstr "\"Arn\""
set KMS_KEY_ARN= ...
set ECS_EXEC_BUCKET_NAME=%DEMO_NAME%-ouput-3240598random
aws kms create-alias --alias-name alias/%DEMO_NAME%-kms-key --target-key-id %KMS_KEY_ARN% --region %AWS_REGION%

aws ecs create-cluster --cluster-name %CLUSTER_NAME% --region %AWS_REGION% --configuration executeCommandConfiguration="{logging=OVERRIDE, kmsKeyId=%KMS_KEY_ARN%, logConfiguration={cloudWatchLogGroupName="/aws/ecs/%DEMO_NAME%", s3BucketName=%ECS_EXEC_BUCKET_NAME%, s3KeyPrefix=exec-output}}"
aws logs create-log-group --log-group-name /aws/ecs/%DEMO_NAME% --region %AWS_REGION%
aws s3api create-bucket --bucket %ECS_EXEC_BUCKET_NAME% --region %AWS_REGION% --create-bucket-configuration LocationConstraint=%AWS_REGION%
set ECS_EXEC_DEMO_SG_ID =`aws ec2 create-security-group --group-name %DEMO_NAME%-SG --description "ECS exec demo SG" --vpc-id %VPC_ID% --region %AWS_REGION%`

aws ec2 authorize-security-group-ingress --group-id %ECS_EXEC_DEMO_SG_ID% --protocol tcp --port 80 --cidr 0.0.0.0/0 --region %AWS_REGION%
echo {"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":["ecs-tasks.amazonaws.com"]},"Action":"sts:AssumeRole"}]} > ecs-tasks-trust-policy.json
aws iam create-role --role-name %DEMO_NAME%-task-execution-role --assume-role-policy-document file://ecs-tasks-trust-policy.json --region %AWS_REGION%
aws iam create-role --role-name %DEMO_NAME%-task-role --assume-role-policy-document file://ecs-tasks-trust-policy.json --region %AWS_REGION%
echo {"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":["ssmmessages:CreateControlChannel","ssmmessages:CreateDataChannel","ssmmessages:OpenControlChannel","ssmmessages:OpenDataChannel"],"Resource":"*"},{"Effect":"Allow","Action":["logs:DescribeLogGroups"],"Resource":"*"},{"Effect":"Allow","Action":["logs:CreateLogStream","logs:DescribeLogStreams","logs:PutLogEvents"],"Resource":"arn:aws:logs:%AWS_REGION%:%AWS_ACCOUNT%:log-group:/aws/ecs/%DEMO_NAME%:*"},{"Effect":"Allow","Action":["s3:PutObject"],"Resource":"arn:aws:s3:::%ECS_EXEC_BUCKET_NAME%/*"},{"Effect":"Allow","Action":["s3:GetEncryptionConfiguration"],"Resource":"arn:aws:s3:::%ECS_EXEC_BUCKET_NAME%"},{"Effect":"Allow","Action":["kms:Decrypt"],"Resource":"%KMS_KEY_ARN%"}]} > %DEMO_NAME%-task-role-policy.json

aws iam attach-role-policy  ^
    --role-name %DEMO_NAME%-task-execution-role ^
    --policy-arn "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    
aws iam put-role-policy ^
    --role-name %DEMO_NAME%-task-role ^
    --policy-name %DEMO_NAME%-task-role-policy ^
    --policy-document file://%DEMO_NAME%-task-role-policy.json

echo {"family":"%DEMO_NAME%","networkMode":"awsvpc","executionRoleArn":"arn:aws:iam::%AWS_ACCOUNT%:role/%DEMO_NAME%-task-execution-role","taskRoleArn":"arn:aws:iam::%AWS_ACCOUNT%:role/%DEMO_NAME%-task-role","containerDefinitions":[{"name":"nginx","image":"nginx","linuxParameters":{"initProcessEnabled":true},"logConfiguration":{"logDriver":"awslogs","options":{"awslogs-group":"/aws/ecs/%DEMO_NAME%","awslogs-region":"%AWS_REGION%","awslogs-stream-prefix":"container-stdout"}}}],"requiresCompatibilities":["FARGATE"],"cpu":"256","memory":"512"} > %DEMO_NAME%.json

aws ecs register-task-definition ^
    --cli-input-json file://%DEMO_NAME%.json ^
    --region %AWS_REGION%

aws ecs run-task ^
    --cluster %CLUSTER_NAME%  ^
    --task-definition %DEMO_NAME% ^
    --network-configuration awsvpcConfiguration="{subnets=[%PUBLIC_SUBNET1%, %PUBLIC_SUBNET2%, %PUBLIC_SUBNET3%],securityGroups=[%ECS_EXEC_DEMO_SG_ID%],assignPublicIp=ENABLED}" ^
    --enable-execute-command ^
    --launch-type FARGATE ^
    --tags key=environment,value=production ^
    --region %AWS_REGION%
@REM Get the TaskID from the JSON output
set TASK_ARN=

aws ecs list-tasks --cluster %CLUSTER_NAME%

@REM Check that it is running
aws ecs describe-tasks --cluster %CLUSTER_NAME% --region %AWS_REGION% --tasks %TASK_ARN%


@REM update the task definition to include the ARN of the IAM role you just created in the "taskRoleArn" field. 


set TASK_DEFINITION_ARN=arn:aws:ecs:eu-central-1:022336740566:task-definition/docker-managementconsole-service:15
aws ecs update-service --service %SERVICE_NAME% --task-definition %TASKDEFINITION_ARN% --cluster %CLUSTER_NAME%

set CONTAINER-NAME=managementconsole-service
aws ecs execute-command --region %AWS_REGION% --cluster %CLUSTER_NAME% --task %TASK_ARN% --container %CONTAINER-NAME% --command "/bin/bash" --interactive



set SERVICE_NAME=docker-ManagementconsoleserviceService-84aGt9ik6776
@REM list all services on a cluster (docker instances)
aws ecs list-services --region %AWS_region% --cluster docker
@REM describe a service on a cluster
aws ecs describe-services --region %AWS_region% --cluster %CLUSTER_NAME% --services %SERVICE_NAME%

@REM Allow MC to have SSN access

@REM IAM=Identity and Access Management
set ROLE_NAME=AllowAssumeRole
set POLICY_NAME=AllowChannelAccess

echo { "Version": "2012-10-17", "Statement": [ { "Sid": "", "Effect": "Allow", "Principal": { "Service": "ecs-tasks.amazonaws.com" }, "Action": "sts:AssumeRole" } ] } > assumerole.json
aws iam create-role --role-name %ROLE_NAME% --assume-role-policy-document file://assumerole.json
set ROLE_ARN=arn:aws:iam::022336740566:role/AllowAssumeRole
echo { "Version": "2012-10-17", "Statement": [ { "Effect": "Allow", "Action": [ "ssmmessages:CreateControlChannel", "ssmmessages:CreateDataChannel", "ssmmessages:OpenControlChannel", "ssmmessages:OpenDataChannel" ], "Resource": "*" } ] } >> policy.json
aws iam create-policy --policy-name %POLICY_NAME% --policy-document file://policy.json 
set POLICY_ARN=arn:aws:iam::022336740566:policy/AllowChannelAccess
aws iam attach-role-policy --policy-arn %POLICY_ARN% --role-name %ROLE_NAME%

@REM Andrew will send me how to create a new task definition with the policy_arn.
@REM https://docs.aws.amazon.com/cli/latest/reference/ecs/register-task-definition.html


aws ecs update-service --service %SERVICE_NAME% --enable-execute-command --cluster %CLUSTER_NAME%

@REM stop and restart a task
aws ecs stop-task  --cluster %CLUSTER_NAME% --region %AWS_REGION%  --task %TASK_ARN%
aws ecs start-task  --cluster %CLUSTER_NAME% --region %AWS_REGION%  --task %TASK_ARN%
