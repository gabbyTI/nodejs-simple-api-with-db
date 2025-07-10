# Create DB subnet group
resource "aws_db_subnet_group" "postgres" {
  name       = "${var.name_prefix}-postgres-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.name_prefix}-postgres-subnet-group"
  }
}

# Create security group for RDS
resource "aws_security_group" "postgres" {
  name_prefix = "${var.name_prefix}-postgres-"
  vpc_id      = var.vpc_id
  description = "Security group for PostgreSQL RDS instance"

  ingress {
    description = "PostgreSQL from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow access from specific security groups if provided
  dynamic "ingress" {
    for_each = var.allowed_security_group_ids
    content {
      description     = "PostgreSQL from security group ${ingress.value}"
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      security_groups = [ingress.value]
    }
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-postgres-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Generate random password if not provided
resource "random_password" "postgres_password" {
  count   = var.master_password == null ? 1 : 0
  length  = 32
  special = true
}

# Store password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "postgres_credentials" {
  name                    = "${var.name_prefix}-postgres-credentials"
  description             = "PostgreSQL database credentials"
  recovery_window_in_days = var.deletion_protection ? 30 : 0

  tags = {
    Name = "${var.name_prefix}-postgres-credentials"
  }
}

resource "aws_secretsmanager_secret_version" "postgres_credentials" {
  secret_id = aws_secretsmanager_secret.postgres_credentials.id
  secret_string = jsonencode({
    username = var.master_username
    password = var.master_password != null ? var.master_password : random_password.postgres_password[0].result
    endpoint = aws_db_instance.postgres.endpoint
    port     = aws_db_instance.postgres.port
    dbname   = aws_db_instance.postgres.db_name
  })
}

# Create RDS instance
resource "aws_db_instance" "postgres" {
  # Basic settings
  identifier = "${var.name_prefix}-postgres"
  engine     = "postgres"
  engine_version = var.postgres_version
  
  # Instance configuration
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id           = var.kms_key_id

  # Database configuration
  db_name  = var.database_name
  username = var.master_username
  password = var.master_password != null ? var.master_password : random_password.postgres_password[0].result
  port     = var.database_port

  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [aws_security_group.postgres.id]
  publicly_accessible    = var.publicly_accessible

  # Backup configuration
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window
  copy_tags_to_snapshot  = true

  # Performance and monitoring
  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_kms_key_id
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn            = var.monitoring_interval > 0 ? aws_iam_role.rds_enhanced_monitoring[0].arn : null
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  # Security and compliance
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name_prefix}-postgres-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Parameters
  parameter_group_name = var.parameter_group_name != null ? var.parameter_group_name : aws_db_parameter_group.postgres[0].name
  option_group_name    = var.option_group_name

  # Multi-AZ and read replicas
  multi_az = var.multi_az

  # Auto minor version upgrade
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  # Apply changes immediately or during maintenance window
  apply_immediately = var.apply_immediately

  tags = var.tags

  depends_on = [
    aws_db_subnet_group.postgres,
    aws_security_group.postgres
  ]
}

# Create custom parameter group if not provided
resource "aws_db_parameter_group" "postgres" {
  count  = var.parameter_group_name == null ? 1 : 0
  family = "postgres${split(".", var.postgres_version)[0]}"
  name   = "${var.name_prefix}-postgres-params"

  dynamic "parameter" {
    for_each = var.custom_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# Enhanced monitoring role (only if monitoring_interval > 0)
resource "aws_iam_role" "rds_enhanced_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0
  name  = "${var.name_prefix}-rds-enhanced-monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count      = var.monitoring_interval > 0 ? 1 : 0
  role       = aws_iam_role.rds_enhanced_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# CloudWatch log groups (if enabled)
resource "aws_cloudwatch_log_group" "postgres" {
  for_each          = toset(var.enabled_cloudwatch_logs_exports)
  name              = "/aws/rds/instance/${aws_db_instance.postgres.identifier}/${each.value}"
  retention_in_days = var.cloudwatch_log_retention_days

  tags = var.tags
}
