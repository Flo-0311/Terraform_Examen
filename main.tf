############################################
# Provider Configuration
############################################
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

############################################
# Network Module
############################################
module "networking" {
  source = "./modules/network"
  
  environment = var.environment
}

############################################
# Database Module
############################################
module "database" {
  source = "./modules/database"
  
  environment           = var.environment
  vpc_id               = module.networking.vpc_id
  private_subnet_ids   = module.networking.private_subnet_ids
  web_security_group_id = module.compute.web_security_group_id
  db_password          = var.db_password
}

############################################
# Load Balancer Module
############################################
module "loadbalancer" {
  source = "./modules/loadbalancer"
  
  environment       = var.environment
  vpc_id           = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
}

############################################
# Compute Module
############################################
module "compute" {
  source = "./modules/compute"
  
  environment           = var.environment
  vpc_id               = module.networking.vpc_id
  vpc_cidr             = module.networking.vpc_cidr
  public_subnet_ids    = module.networking.public_subnet_ids  # ← KORRIGIERT!
  private_subnet_ids   = module.networking.private_subnet_ids
  alb_security_group_id = module.loadbalancer.alb_security_group_id
  target_group_arn     = module.loadbalancer.target_group_arn
  db_endpoint          = module.database.db_endpoint
  db_name              = module.database.db_name
  db_username          = module.database.db_username
  db_password          = module.database.db_password
}
