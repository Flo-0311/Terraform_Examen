module "compute" {
  source      = "./modules/compute"
  environment = var.environment

  vpc_id      = module.network.vpc_id
  subnet_ids  = module.network.public_subnets
  var_cidr =    module.network.cidr
}

module "network" {
  source      = "./modules/network"
  environment = var.environment

}

module "database" {
  source      = "./modules/database"
  environment = var.environment
}

module "loadbalancer" {
  source      = "./modules/loadbalancer"
  environment = var.environment
}


terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~>5.0"
        }
    }
}

provider "aws" {
    region = "eu-west-3"
}

