# terraform-aws-wordpress-ecs

Terraform module which deploys Wordpress on AWS using ECS Fargate for compute, RDS for database and an application load balancer.

## Example Usage

```hcl
provider "aws" {
  region  = "us-east-1"
}

module "vpc" {
   source = "terraform-aws-modules/vpc/aws"
   name = "wordpress"
   cidr = "10.0.0.0/16"
   azs = ["us-east-1a", "us-east-1b"]
   public_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
   private_subnets = ["10.0.2.0/24", "10.0.3.0/24"]
   intra_subnets = ["10.0.4.0/24", "10.0.5.0/24"]
   database_subnets = ["10.0.6.0/24", "10.0.7.0/24"]
   enable_nat_gateway = true
   enable_dns_hostnames = true
}

module "wordpress" {
   source = "../terraform-aws-wordpress-ecs"
   ecs_service_subnet_ids = module.vpc.private_subnets
   lb_subnet_ids = module.vpc.public_subnets
   db_subnet_group_subnet_ids = module.vpc.database_subnets
}
```
