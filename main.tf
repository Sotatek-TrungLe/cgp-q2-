/* Initial terraform configuration */

terraform {
  backend "s3" {
    bucket = "terraform-da-q2"
    key    = "terraform.tfstate"
    region = "ap-east-1"
    profile   = "da-q2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.15.1"
    }
  }
}

provider "aws" {
  profile = "da-q2"
  region  = "ap-east-1"
}

/* Declaring a Local Value */

locals {
  common = {
    project = "${var.project}"
    env = "${var.env}"
  }
  network = {
    vpc_id = "${module.vpc.vpc_id}"
    subnet_ids = "${module.vpc.private_subnet_ids}"
  }  
}

/* Importing VPC networking module */ 

module "vpc" {
  source = "./modules/vpc"
  common = local.common

  vpc_cidr = var.vpc_cidr
  subnet_az = var.subnet_az
  enable_nat_gw = var.enable_nat_gw
  
}

/* Importing secretmanager module 
   For generating the secret rds password
*/ 

module "rds_secret" {
  source = "./modules/secretmanager"
  common = local.common
  secret_name = "${var.rds_name}/password"

}

# If you want use the existing secret

# data "aws_secretsmanager_secret" "rds_password" {
#   name = "/${local.common.env}/${local.common.project}/${var.rds_name}/existing-password"

# }
# data "aws_secretsmanager_secret_version" "rds_password" {
#   secret_id = data.aws_secretsmanager_secret.rds_password.id
# }

# /* Importing RDS module */ 

module "rds" {
  source = "./modules/rds"
  common = local.common
  network = local.network

  allowed_sg_ids_access_rds = var.allowed_sg_ids_access_rds
  allowed_cidr_blocks_access_rds = var.allowed_cidr_blocks_access_rds

  rds_name = var.rds_name
  multi_az = var.multi_az

  rds_storage = var.rds_storage
  rds_max_storage = var.rds_max_storage
  rds_storage_type = var.rds_storage_type
  rds_iops = var.rds_iops

  rds_class = var.rds_class
  rds_family = var.rds_family
  rds_engine = var.rds_engine
  rds_engine_version = var.rds_engine_version
  rds_port = var.rds_port
  rds_username = var.rds_username
  # rds_password = data.aws_secretsmanager_secret_version.rds_password.secret_string
  rds_password = "${module.rds_secret.secret}"
  rds_backup_retention_period =  var.rds_backup_retention_period
  aws_db_parameters = var.aws_db_parameters
}
