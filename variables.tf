# Common variables
variable "project" {
  type        = string
  description = "Project name"
}

variable "env" {
  type        = string
  description = "Environment name"
}

# VPC variables
variable "vpc_cidr" {
  type        = string
  description = "The IP range to use for the VPC"
}

variable "subnet_az" {
  type = map(number)
  description = "Map of AZ to a number that should be used for subnets"
}

variable "enable_nat_gw" {
  description = "If set to true, it will create nat gw"
  type = bool
}

# # Rds variables

variable "allowed_sg_ids_access_rds" {
  type    = list(string)
}

variable "allowed_cidr_blocks_access_rds" {
  type    = list(string)
}

variable "multi_az" {
  description = "If set to true, RDS instance is multi-AZ"
  type = bool
}

variable "rds_name" {
  type = string
}

variable "rds_class" {
  type = string
}

variable "rds_storage" {
  type = string
}

variable "rds_max_storage" {
  type = string
}

variable "rds_storage_type" {
  type = string
}

variable "rds_iops" {
  type = number
}

variable "rds_family" {
  type = string
}

variable "rds_engine" {
  type = string
}

variable "rds_engine_version" {
  type = string
}

variable "rds_port" {
  type = string
}

variable "rds_username" {
  type = string
}

variable "rds_backup_retention_period" {
  type = number
}

variable "aws_db_parameters" {
  type = map(number)
  description = "Custom parameters for RDS instance"
}