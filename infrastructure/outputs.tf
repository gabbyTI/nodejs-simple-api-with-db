# Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}
output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr
}

output "db_endpoint" {
  description = "Database endpoint"
  value       = module.postgres_db.endpoint
}

output "db_port" {
  description = "Database port"
  value       = module.postgres_db.port
}

output "db_name" {
  description = "Database name"
  value       = module.postgres_db.database_name
}

output "db_username" {
  description = "Database username"
  value       = module.postgres_db.username
}

output "db_security_group_id" {
  description = "Database security group ID"
  value       = module.postgres_db.security_group_id
}

output "db_connection_string" {
  description = "Database connection string"
  value       = module.postgres_db.connection_string
  sensitive   = true
}

output "db_secrets_manager_secret_id" {
  description = "Secrets Manager secret ID for database credentials"
  value       = module.postgres_db.secrets_manager_secret_id
}

output "db_secrets_manager_secret_arn" {
  description = "Secrets Manager secret ARN for database credentials"
  value       = module.postgres_db.secrets_manager_secret_arn
}

output "app_security_group_id" {
  description = "Security group ID for application servers"
  value       = aws_security_group.app.id
}

# Environment-specific configuration examples
output "deployment_instructions" {
  description = "Instructions for deploying applications"
  sensitive   = true
  value       = <<-EOT
    
    === Database Connection Information ===
    
    Environment: ${var.environment}
    Database Endpoint: ${module.postgres_db.endpoint}
    Database Name: ${module.postgres_db.database_name}
    
    === For Node.js Applications ===
    
    1. Retrieve database credentials from AWS Secrets Manager:
       aws secretsmanager get-secret-value --secret-id ${module.postgres_db.secrets_manager_secret_id}
    
    2. Use this environment variable in your Node.js app:
       DATABASE_URL="${module.postgres_db.connection_string}"
    
    3. Or use individual components:
       DB_HOST="${module.postgres_db.endpoint}"
       DB_PORT="${module.postgres_db.port}"
       DB_NAME="${module.postgres_db.database_name}"
       DB_USER="${module.postgres_db.username}"
       # DB_PASSWORD - retrieve from Secrets Manager
    
    4. Example .env file for your Node.js application:
       DATABASE_URL=postgresql://username:password@host:port/database
       DB_HOST=${module.postgres_db.endpoint}
       DB_PORT=${module.postgres_db.port}
       DB_NAME=${module.postgres_db.database_name}
       DB_USER=${module.postgres_db.username}
       # Set DB_PASSWORD from Secrets Manager value
    
    === Security Groups ===
    
    App Security Group: ${aws_security_group.app.id}
    DB Security Group: ${module.postgres_db.security_group_id}
    
    === Monitoring ===
    
    Performance Insights: Enabled
    CloudWatch Logs: /aws/rds/instance/${module.postgres_db.database_name}/postgresql
    
    === Application Server ===
    
    EC2 Instance: ${module.vm.instance_id}
    Public IP: ${module.app_server.public_ip}
    Security Group: ${aws_security_group.app.id}
    
    === Next Steps ===
    
    1. Deploy your application code to the EC2 instance
    2. Configure environment variables with database credentials
    3. Set up application monitoring and logging
    4. Configure SSL/TLS certificates for production
    5. Set up automated backups and monitoring alerts
    
    === SSH Connection ===
    
    To connect to your EC2 instance:
    ssh -i your-key.pem ec2-user@${module.app_server.public_ip}
    
    === Application Deployment ===
    
    1. Install Node.js and npm on the EC2 instance
    2. Clone your application repository
    3. Install dependencies: npm install
    4. Set environment variables from Secrets Manager
    5. Start your application: npm start
    
  EOT
}
