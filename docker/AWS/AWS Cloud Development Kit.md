# Deploy Kofax RPA on AWS Cloud Development Kit

typescript samples on GitHub https://github.com/aws-samples/aws-cdk-examples  
[Typescript examples](https://github.com/aws-samples/aws-cdk-examples/tree/master/typescript)  
[fargate-application-load-balanced-service](https://github.com/aws-samples/aws-cdk-examples/tree/master/typescript/ecs/fargate-application-load-balanced-service/)

Design in drawio.corp.amazon.com  
![](img/2021-11-24-15-54-50.png)

* [install typescript](https://github.com/aws-samples/aws-cdk-examples/tree/master/typescript#typescript-examples)  
* in VS Code  
![](img/2021-11-24-15-57-29.png)

[Getting started with CDK](https://docs.aws.amazon.com/cdk/latest/guide/getting_started.html) 


# Install CDK
* install [Node.js installer](https://nodejs.org/en/download/)
* at commandline run
```
C:\Windows\System32\cmd.exe /k "C:\Program Files\nodejs\nodevars.bat"
npm install -g typescript
npm install -g aws-cdk
cd %USERPROFILE%\AppData\Roaming\npm\node_modules
cd aws-cdk
```
[Create a new CDK project](https://docs.aws.amazon.com/cdk/latest/guide/work-with-cdk-typescript.html)
```
mkdir cdk-sample
cd cdk-sample
rem view available templates
cdk init
code .
cdk init sample-app --language=typescript
```
## Edit your CDK project
* Delete the definition of the variable **queue** (lines 10-16) from **lib\cdk-sample-stack.ts**  
* delete the first 3 imports.
* Open https://github.com/aws-samples/aws-cdk-examples/blob/master/typescript/ecs/fargate-application-load-balanced-service/index.ts
* copy the first 3 dependencies
* copy the **vpc** (Virtual Private Cloud), **cluster** and **ecs_patterns** definitions
```typescript
import ec2 = require('@aws-cdk/aws-ec2');
import ecs = require('@aws-cdk/aws-ecs');
import ecs_patterns = require('@aws-cdk/aws-ecs-patterns');
import * as cdk from '@aws-cdk/core';

export class CdkSampleStack extends cdk.Stack {
  constructor(scope: cdk.App, id: string, props?: cdk.StackProps) {
    super(scope, id, props);
    
    // Create VPC and Fargate Cluster
    // NOTE: Limit AZs to avoid reaching resource quotas
    const vpc = new ec2.Vpc(this, 'MyVpc', { maxAzs: 2 });  //Az use a max of 2 Availability Zones in the region https://aws.amazon.com/about-aws/global-infrastructure/regions_az/
    const cluster = new ecs.Cluster(this, 'Cluster', { vpc });

    // Instantiate Fargate Service with just cluster and image
    new ecs_patterns.ApplicationLoadBalancedFargateService(this, "FargateService", {
      cluster,
      taskImageOptions: {
        image: ecs.ContainerImage.fromRegistry("amazon/amazon-ecs-sample"),  // a Docker container from Docker Hub
      },
    });
    
  }
}
```
* Change the 3 dependencies to **package.json** keeping the same version number as **core**. (12:19)
```json
  "dependencies": {
    "@aws-cdk/core": "1.134.0",
    "@aws-cdk/aws-ec2": "1.134.0",
    "@aws-cdk/aws-ecs": "1.134.0",
    "@aws-cdk/aws-ecs-patterns": "1.134.0"
  }
```
* install your app 
```cmd
rem install dependencies
npm install
cdk deploy
REM view it at https://eu-central-1.console.aws.amazon.com/cloudformation/home
cdk destroy
```