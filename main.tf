module "compute" {
  source      = "./modules/compute"
  environment = var.environment

  vpc_id      = module.network.vpc_id
  subnet_ids  = module.network.public_subnets
  private_subnet_ids = module.network.privat_subnets
  vpc_cidr =    module.network.vpc_cidr
  db_username = module.database.db_username
  db_password = module.database.db_password
  db_name = module.database.db_name
  db_endpoint = module.database.db_endpoint
  target_group_arn = module.loadbalancer.target_group_arn
}

module "network" {
  source      = "./modules/network"
  environment = var.environment

}

module "database" {
  source      = "./modules/database"
  environment = var.environment
  vpc_cidr =    module.network.vpc_cidr
  vpc_id      = module.network.vpc_id
  privat_ids = module.network.privat_subnets
  sg_80 = module.compute.sg_80

}

module "loadbalancer" {
  source      = "./modules/loadbalancer"
  environment = var.environment
  subnet_ids  = module.network.public_subnets
  vpc_id      = module.network.vpc_id
  vpc_cidr =    module.network.vpc_cidr
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

