# Common variables
project = "data-analytics"
env = "qa"

# VPC variables
vpc_cidr = "10.0.0.0/16"

subnet_az = {
  "ap-east-1a" = 1
  "ap-east-1c" = 2
}

enable_nat_gw = false

# # Rds variables

allowed_sg_ids_access_rds = [] # Depends on your requirement

allowed_cidr_blocks_access_rds = ["10.0.0.0/16"] # Depends on your requirement

multi_az = true

rds_name = "test"
rds_class = "db.m5.2xlarge" #db.t3.xlarge

rds_storage_type = "io1" # gp2
rds_iops = 16000   # Adujst on your app requirements

rds_storage = 20
rds_max_storage = 1000
rds_username = "test"
rds_family = "postgres13"
rds_engine = "postgres"
rds_engine_version = "13.9"
rds_port = 5432
rds_backup_retention_period = 30

aws_db_parameters = {
  "log_min_duration_statement" = 300 #slow query if query time > 300 ms
}
