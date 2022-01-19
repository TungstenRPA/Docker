# Deploy Cloudfront Application to Amazon MarketPlace

[Deployment Guide](https://docs.aws.amazon.com/marketplace/latest/userguide/cloudformation.html)

[Template and Best Practices for Sellers](https://aws.amazon.com/blogs/awsmarketplace/cloudformation-templates-101-for-sellers-in-aws-marketplace/)
* don't hardcode VPCs and subnets - customers might have their own
* default password to instance id.

[Custom Wizard Interface in Cloudformation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-cloudformation-interface.html)
* how to use Cloudformation Interface in CDK [github article](https://github.com/aws/aws-cdk/issues/5944#issuecomment-581365345)

On Marketplace
* use AMI or containers
Amazon Marketplace can clone our containers to a region and keep them "private".
  They can pull the repos when subscribed, and lose access to the repo when end subscriptions.
Amazon expects a subscription model within 90 days of BYOL going public. we can stay hidden as long as you like. - i can whitelist accounts to test our product.

Two options
* EKS - elastic kubernetes service.
* ECS - elastic container service. 
the compute layer is EC2 or Fargate.  

CDK + ECS + Fargate.
[Blog article](https://aws.amazon.com/blogs/awsmarketplace/creating-container-products-for-aws-marketplace-using-amazon-eks-and-aws-fargate/) 
Oscar on GitHub (ozzambra) ,ozzambra@amazon.de, Carrasquero, Oscar
[EKS & Fargate](https://github.com/aws-samples/aws-marketplace-metered-container-product/tree/master)

**  AMMP Amazon AWS MarketPlace Management Portal
[Marketplace with ECS](https://docs.aws.amazon.com/marketplace/latest/userguide/container-product-getting-started.html)
[AMI-based delivery using AWS CloudFormation](https://docs.aws.amazon.com/marketplace/latest/userguide/cloudformation.html)