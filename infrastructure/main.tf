data "aws_ami" "vibesmeet" {
  most_recent = true
  owners      = ["amazon"]
}

# Create VPC using the VPC module
module "vpc" {
  source = "./_modules/vpc-module"

  name_prefix              = "${var.project_name}-${var.environment}"
  vpc_cidr                 = "10.0.0.0/16"
  public_subnet_cidr_bits  = 8 # Creates /24 subnets (10.0.0.0/24, 10.0.1.0/24, etc.)
  private_subnet_cidr_bits = 8 # Creates /24 subnets (10.0.10.0/24, 10.0.11.0/24, etc.)
}

# Create RDS PostgreSQL database using the RDS module
module "database" {
  source = "./_modules/rds-postgres-module/"

  # Required variables
  name_prefix        = "${var.project_name}-${var.environment}"
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = "10.0.0.0/16"
  private_subnet_ids = module.vpc.private_subnet_ids

  # Database configuration
  database_name    = "nodejs_app"
  master_username  = "app_user"
  postgres_version = "16.4"

  # Instance configuration for production
  instance_class        = "db.t4g.micro"
  allocated_storage     = 20
  max_allocated_storage = 50
  storage_type          = "gp3"
  storage_encrypted     = true

  # High availability and backup (adjust for environment)
  multi_az                = var.environment == "production" ? true : false
  backup_retention_period = var.environment == "production" ? 14 : 7
  deletion_protection     = var.environment == "production" ? true : false
  skip_final_snapshot     = var.environment == "production" ? false : true

  # Security - allow access from application security group
  allowed_security_group_ids = [aws_security_group.app.id]

  # Monitoring and logging
  performance_insights_enabled    = true
  monitoring_interval             = var.environment == "production" ? 15 : 60
  enabled_cloudwatch_logs_exports = ["postgresql"]
  cloudwatch_log_retention_days   = var.environment == "production" ? 30 : 7

  # Custom PostgreSQL parameters for Node.js apps
  custom_parameters = [
    {
      name  = "shared_preload_libraries"
      value = "pg_stat_statements"
    },
    {
      name  = "log_statement"
      value = "all"
    },
    {
      name  = "log_min_duration_statement"
      value = "1000" # Log queries slower than 1 second
    },
    {
      name  = "max_connections"
      value = "100"
    },
    {
      name  = "shared_buffers"
      value = "{DBInstanceClassMemory/4}" # 25% of instance memory
    }
  ]

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Backup      = "required"
    Owner       = "platform-team"
  }
}

module "vm" {
  source             = "./_modules/ec2-instance-with-static-eip"
  instance_name      = "${var.project_name}-${var.environment}-app-server"
  security_group_ids = [aws_security_group.app.id]
  ami                = "ami-0cb91c7de36eed2cb" # Replace with your AMI ID
  instance_type      = "t4g.micro"
  environment        = var.environment
}
