variable "common" {
  type = object({
    project = string
    env = string
  })
}

variable "allowed_sg_ids_access_rds" {
  type    = list(string)
}

variable "allowed_cidr_blocks_access_rds" {
  type    = list(string)
}

variable "rds_name" {
  type = string
}

variable "multi_az" {
  description = "If set to true, RDS instance is multi-AZ"
  type = bool
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

variable "rds_password" {
  type = string
}

variable "rds_backup_retention_period" {
  type = number
}

variable "network" {
  type = object({
    vpc_id = string
    subnet_ids = list(string)
  })
}

variable "aws_db_parameters" {
  type = map(number)
  description = "Custom parameters for RDS instance"
}