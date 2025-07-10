# Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "database_endpoint" {
  description = "RDS instance endpoint"
  value       = module.database.db_instance_endpoint
}

output "database_port" {
  description = "RDS instance port"
  value       = module.database.db_instance_port
}

output "database_name" {
  description = "Database name"
  value       = module.database.db_instance_name
}

output "database_username" {
  description = "Database master username"
  value       = module.database.db_instance_username
  sensitive   = true
}

output "database_secret_arn" {
  description = "ARN of the secret containing database credentials"
  value       = module.database.secrets_manager_secret_arn
}

output "database_connection_string" {
  description = "Database connection string for applications"
  value       = module.database.connection_string
  sensitive   = true
}

output "database_security_group_id" {
  description = "Security group ID for the database"
  value       = module.database.security_group_id
}

output "app_security_group_id" {
  description = "Security group ID for application servers"
  value       = aws_security_group.app.id
}

# Environment-specific configuration examples
output "deployment_instructions" {
  description = "Instructions for deploying applications"
  value       = <<-EOT
    
    === Database Connection Information ===
    
    Environment: ${var.environment}
    Database Endpoint: ${module.database.db_instance_endpoint}
    Database Name: ${module.database.db_instance_name}
    
    === For Node.js Applications ===
    
    1. Retrieve database credentials from AWS Secrets Manager:
       aws secretsmanager get-secret-value --secret-id ${module.database.secrets_manager_secret_arn}
    
    2. Use this environment variable in your Node.js app:
       DATABASE_URL="${module.database.connection_string}"
    
    3. Or use individual components:
       DB_HOST="${module.database.db_instance_address}"
       DB_PORT="${module.database.db_instance_port}"
       DB_NAME="${module.database.db_instance_name}"
       DB_USER="${module.database.db_instance_username}"
       # DB_PASSWORD - retrieve from Secrets Manager
    
    === Security Groups ===
    
    App Security Group: ${aws_security_group.app.id}
    DB Security Group: ${module.database.security_group_id}
    
    === Monitoring ===
    
    Performance Insights: Enabled
    CloudWatch Logs: /aws/rds/instance/${module.database.db_instance_id}/postgresql
    
  EOT
}
