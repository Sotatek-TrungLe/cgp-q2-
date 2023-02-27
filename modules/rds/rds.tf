resource "aws_security_group" "sg_db" {
  name = "${var.common.env}-${var.common.project}-sg-${var.rds_name}"
  description = "SG for db"
  vpc_id = var.network.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "sg_rule_db_from_sg_ids" {
  count = length(var.allowed_sg_ids_access_rds)

  type = "ingress"
  from_port = var.rds_port
  to_port = var.rds_port
  protocol = "TCP"
  source_security_group_id = var.allowed_sg_ids_access_rds[count.index]
  security_group_id = aws_security_group.sg_db.id
  description = "From sg ${var.allowed_sg_ids_access_rds[count.index]}"
}

resource "aws_security_group_rule" "sg_rule_db_from_cidr_blocks" {
  count = length(var.allowed_cidr_blocks_access_rds)

  type = "ingress"
  from_port = var.rds_port
  to_port = var.rds_port
  protocol = "TCP"
  cidr_blocks = var.allowed_cidr_blocks_access_rds
  security_group_id = aws_security_group.sg_db.id
  description = "From cidr ${var.allowed_cidr_blocks_access_rds[count.index]}"
}

resource "aws_db_parameter_group" "db_parameter_group" {
  name   = "${var.common.env}-${var.common.project}-${var.rds_name}"
  family = var.rds_family

  dynamic "parameter" {
      for_each = var.aws_db_parameters
      content {
        name = parameter.key
        value = parameter.value
      }
    }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.common.env}-${var.common.project}-${var.rds_name}"
  subnet_ids = var.network.subnet_ids
}

resource "aws_db_instance" "db" {
  identifier = "${var.common.env}-${var.common.project}-${var.rds_name}"
  multi_az = var.multi_az
  allocated_storage    = var.rds_storage
  max_allocated_storage = var.rds_max_storage

  storage_type         = var.rds_storage_type
  iops                 = var.rds_storage_type == "io1" ? var.rds_iops : null

  engine               = var.rds_engine
  engine_version       = var.rds_engine_version
  instance_class       = var.rds_class
  db_name              = replace("${var.rds_name}", "-", "_")
  username             = var.rds_username
  password             = var.rds_password
  port                 = var.rds_port
  parameter_group_name = aws_db_parameter_group.db_parameter_group.name
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.sg_db.id]

  performance_insights_enabled = true
  skip_final_snapshot  = true # if you want snapshot before deleteing set to false

  # apply_immediately = true
  # final_snapshot_identifier = "${var.common.env}-${var.common.project}-${var.rds_name}-final"

  allow_major_version_upgrade = false
  auto_minor_version_upgrade = false

  lifecycle {
    ignore_changes = [publicly_accessible]
  }
  backup_retention_period = var.rds_backup_retention_period
  backup_window = "00:30-01:30"
  maintenance_window = "sat:04:30-sat:05:30"
}

## if you want to implement cross-region replication

# resource "aws_db_instance_automated_backups_replication" "db_automated_backup" {
#   source_db_instance_arn = "arn:aws:rds:XXXX:YYY:db:${var.common.env}-${var.common.project}"
#   retention_period       = 14
# }