resource "random_password" "master"{
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret" "password" {
  name = "/${var.common.env}/${var.common.project}/${var.secret_name}"
  recovery_window_in_days = 30
}

resource "aws_secretsmanager_secret_version" "password" {
  secret_id = aws_secretsmanager_secret.password.id
  secret_string = random_password.master.result
}

output "secret" {
  value = aws_secretsmanager_secret_version.password.secret_string
}