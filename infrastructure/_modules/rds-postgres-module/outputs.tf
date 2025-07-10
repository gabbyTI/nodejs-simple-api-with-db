# Database Instance Outputs
output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.postgres.id
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.postgres.arn
}

output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "db_instance_address" {
  description = "RDS instance hostname"
  value       = aws_db_instance.postgres.address
}

output "db_instance_port" {
  description = "RDS instance port"
  value       = aws_db_instance.postgres.port
}

output "db_instance_name" {
  description = "Database name"
  value       = aws_db_instance.postgres.db_name
}

output "db_instance_username" {
  description = "Database master username"
  value       = aws_db_instance.postgres.username
  sensitive   = true
}

output "db_instance_engine_version" {
  description = "Database engine version"
  value       = aws_db_instance.postgres.engine_version
}

output "db_instance_class" {
  description = "Database instance class"
  value       = aws_db_instance.postgres.instance_class
}

output "db_instance_status" {
  description = "Database instance status"
  value       = aws_db_instance.postgres.status
}

output "db_instance_availability_zone" {
  description = "Database instance availability zone"
  value       = aws_db_instance.postgres.availability_zone
}

output "db_instance_multi_az" {
  description = "Whether the database instance is multi-AZ"
  value       = aws_db_instance.postgres.multi_az
}

# Security Group Outputs
output "security_group_id" {
  description = "ID of the security group for the RDS instance"
  value       = aws_security_group.postgres.id
}

output "security_group_arn" {
  description = "ARN of the security group for the RDS instance"
  value       = aws_security_group.postgres.arn
}

# Subnet Group Outputs
output "db_subnet_group_id" {
  description = "Database subnet group ID"
  value       = aws_db_subnet_group.postgres.id
}

output "db_subnet_group_arn" {
  description = "Database subnet group ARN"
  value       = aws_db_subnet_group.postgres.arn
}

# Parameter Group Outputs
output "db_parameter_group_id" {
  description = "Database parameter group ID"
  value       = var.parameter_group_name != null ? var.parameter_group_name : aws_db_parameter_group.postgres[0].id
}

# Secrets Manager Outputs
output "secrets_manager_secret_id" {
  description = "Secrets Manager secret ID containing database credentials"
  value       = aws_secretsmanager_secret.postgres_credentials.id
}

output "secrets_manager_secret_arn" {
  description = "Secrets Manager secret ARN containing database credentials"
  value       = aws_secretsmanager_secret.postgres_credentials.arn
}

# Connection Information
output "connection_string" {
  description = "PostgreSQL connection string (without password)"
  value       = "postgresql://${aws_db_instance.postgres.username}@${aws_db_instance.postgres.endpoint}/${aws_db_instance.postgres.db_name}"
  sensitive   = true
}

output "jdbc_connection_string" {
  description = "JDBC connection string (without password)"
  value       = "jdbc:postgresql://${aws_db_instance.postgres.endpoint}:${aws_db_instance.postgres.port}/${aws_db_instance.postgres.db_name}"
}

# Monitoring Outputs
output "enhanced_monitoring_iam_role_arn" {
  description = "Enhanced monitoring IAM role ARN"
  value       = var.monitoring_interval > 0 ? aws_iam_role.rds_enhanced_monitoring[0].arn : null
}

output "cloudwatch_log_groups" {
  description = "CloudWatch log groups for RDS logs"
  value       = { for log_type in var.enabled_cloudwatch_logs_exports : log_type => aws_cloudwatch_log_group.postgres[log_type].name }
}
