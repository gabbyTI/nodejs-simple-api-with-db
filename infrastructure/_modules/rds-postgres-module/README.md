# 🐘 RDS PostgreSQL Terraform Module

This module provisions a production-ready **AWS RDS PostgreSQL database** with:

- **Latest PostgreSQL 16.4** with optimized configuration
- **Automated password management** via AWS Secrets Manager
- **Enhanced monitoring** and Performance Insights
- **Multi-AZ support** for high availability
- **Encryption at rest** and in transit
- **Automated backups** with customizable retention
- **CloudWatch logging** integration
- **Security groups** with least-privilege access

---

## 📁 Features

- ✅ **Security First**: Encrypted storage, VPC isolation, secure credential management
- ✅ **Production Ready**: Multi-AZ, automated backups, monitoring
- ✅ **Cost Optimized**: GP3 storage, right-sized instances, auto-scaling storage
- ✅ **Observability**: Performance Insights, CloudWatch logs, enhanced monitoring
- ✅ **Flexible**: Customizable parameters, multiple instance classes
- ✅ **Infrastructure as Code**: Full Terraform configuration with best practices

---

## 📦 Usage

### Module Structure

```
rds-postgres-module/
├── main.tf          # Main resources
├── variables.tf     # Input variables
├── outputs.tf       # Output values
└── README.md        # This file
```

### Basic Example

```hcl
module "database" {
  source = "../_modules/rds-postgres-module"
  
  # Required variables
  name_prefix        = "myapp"
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = "10.0.0.0/16"
  private_subnet_ids = module.vpc.private_subnet_ids
  
  # Database configuration
  database_name    = "myapp_production"
  master_username  = "app_user"
  instance_class   = "db.t3.small"
  
  # Storage configuration
  allocated_storage     = 50
  max_allocated_storage = 200
  storage_encrypted     = true
  
  # High availability and backup
  multi_az                = true
  backup_retention_period = 14
  deletion_protection     = true
  
  # Security
  allowed_security_group_ids = [aws_security_group.app.id]
  
  tags = {
    Environment = "production"
    Project     = "myapp"
  }
}
```

### Development Example

```hcl
module "dev_database" {
  source = "../_modules/rds-postgres-module"
  
  name_prefix        = "myapp-dev"
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = "10.0.0.0/16"
  private_subnet_ids = module.vpc.private_subnet_ids
  
  # Smaller instance for development
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  max_allocated_storage   = 50
  
  # Relaxed settings for dev
  multi_az                = false
  backup_retention_period = 1
  deletion_protection     = false
  skip_final_snapshot     = true
  
  tags = {
    Environment = "development"
  }
}
```

---

## 🔧 Inputs

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| `name_prefix` | Prefix for resource naming | `string` |
| `vpc_id` | VPC ID where RDS will be deployed | `string` |
| `vpc_cidr` | VPC CIDR block for security group rules | `string` |
| `private_subnet_ids` | List of private subnet IDs | `list(string)` |

### Database Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `database_name` | Initial database name | `string` | `"app_db"` |
| `master_username` | Master username | `string` | `"postgres"` |
| `master_password` | Master password (null = auto-generated) | `string` | `null` |
| `database_port` | Database port | `number` | `5432` |
| `postgres_version` | PostgreSQL version | `string` | `"16.4"` |

### Instance Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `instance_class` | RDS instance class | `string` | `"db.t3.micro"` |
| `allocated_storage` | Initial storage (GB) | `number` | `20` |
| `max_allocated_storage` | Max auto-scaling storage (GB) | `number` | `100` |
| `storage_type` | Storage type (gp2, gp3, io1, io2) | `string` | `"gp3"` |
| `storage_encrypted` | Enable encryption | `bool` | `true` |

### High Availability & Backup

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `multi_az` | Enable Multi-AZ deployment | `bool` | `false` |
| `backup_retention_period` | Backup retention days (0-35) | `number` | `7` |
| `backup_window` | Backup window (UTC) | `string` | `"03:00-04:00"` |
| `maintenance_window` | Maintenance window (UTC) | `string` | `"sun:04:00-sun:05:00"` |

### Security & Network

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `publicly_accessible` | Make publicly accessible | `bool` | `false` |
| `allowed_security_group_ids` | Allowed security group IDs | `list(string)` | `[]` |
| `deletion_protection` | Enable deletion protection | `bool` | `true` |

### Monitoring & Logging

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `performance_insights_enabled` | Enable Performance Insights | `bool` | `true` |
| `monitoring_interval` | Enhanced monitoring interval (seconds) | `number` | `60` |
| `enabled_cloudwatch_logs_exports` | CloudWatch log types | `list(string)` | `["postgresql"]` |
| `cloudwatch_log_retention_days` | Log retention days | `number` | `7` |

---

## 📤 Outputs

### Connection Information

| Name | Description |
|------|-------------|
| `db_instance_endpoint` | Database endpoint |
| `db_instance_address` | Database hostname |
| `db_instance_port` | Database port |
| `connection_string` | PostgreSQL connection string |
| `jdbc_connection_string` | JDBC connection string |

### Security & Credentials

| Name | Description |
|------|-------------|
| `secrets_manager_secret_arn` | Secrets Manager ARN for credentials |
| `security_group_id` | Security group ID |

### Instance Details

| Name | Description |
|------|-------------|
| `db_instance_id` | RDS instance ID |
| `db_instance_arn` | RDS instance ARN |
| `db_instance_status` | Instance status |
| `db_instance_availability_zone` | Instance AZ |

---

## 🔐 Security Features

### Encryption
- **Storage encryption** enabled by default using AWS KMS
- **In-transit encryption** via SSL/TLS
- **Performance Insights encryption** for monitoring data

### Network Security
- **VPC isolation** - Database deployed in private subnets only
- **Security groups** with minimal required access
- **No public accessibility** by default

### Credential Management
- **AWS Secrets Manager** integration for secure password storage
- **Auto-generated passwords** if not provided
- **Rotation support** ready for future implementation

---

## 📊 Monitoring & Observability

### Performance Insights
- **Query performance** monitoring enabled
- **Wait events** and **top SQL** analysis
- **Historical performance** data retention

### CloudWatch Integration
- **PostgreSQL logs** exported to CloudWatch
- **Enhanced monitoring** with 1-minute granularity
- **Custom CloudWatch alarms** can be added

### Backup & Recovery
- **Automated daily backups** with point-in-time recovery
- **Cross-region backup** support
- **Final snapshot** protection before deletion

---

## 💰 Cost Optimization

### Storage
- **GP3 storage** for better price/performance ratio
- **Auto-scaling storage** to prevent over-provisioning
- **Backup optimization** with configurable retention

### Instance Sizing
- **T3 instances** with burstable performance for variable workloads
- **Right-sizing examples** for different environments
- **Multi-AZ only when needed** for production workloads

---

## 🚀 Getting Database Credentials

After deployment, retrieve credentials from AWS Secrets Manager:

```bash
# Using AWS CLI
aws secretsmanager get-secret-value \
  --secret-id myapp-postgres-credentials \
  --query SecretString --output text | jq .

# Using Node.js application
const AWS = require('aws-sdk');
const client = new AWS.SecretsManager();
const secret = await client.getSecretValue({
  SecretId: 'myapp-postgres-credentials'
}).promise();
const credentials = JSON.parse(secret.SecretString);
```

---

## 📋 Instance Class Recommendations

| Environment | Instance Class | vCPUs | RAM | Network | Use Case |
|-------------|----------------|-------|-----|---------|----------|
| **Development** | `db.t3.micro` | 2 | 1 GB | Low-Moderate | Development, testing |
| **Staging** | `db.t3.small` | 2 | 2 GB | Low-Moderate | Staging, small workloads |
| **Production (Small)** | `db.t3.medium` | 2 | 4 GB | Low-Moderate | Small production apps |
| **Production (Medium)** | `db.r5.large` | 2 | 16 GB | Up to 10 Gbps | Memory-intensive workloads |
| **Production (Large)** | `db.r5.xlarge` | 4 | 32 GB | Up to 10 Gbps | High-performance applications |

---

## ✅ Requirements

- **Terraform** >= 1.0
- **AWS Provider** >= 5.0
- **VPC** with private subnets
- **Appropriate IAM permissions** for RDS, Secrets Manager, and CloudWatch

---

## 🔗 Integration Examples

### With Application Load Balancer
```hcl
# App security group can access database
resource "aws_security_group_rule" "app_to_db" {
  type                     = "egress"
  from_port                = module.database.db_instance_port
  to_port                  = module.database.db_instance_port
  protocol                 = "tcp"
  source_security_group_id = module.database.security_group_id
  security_group_id        = aws_security_group.app.id
}
```

### With Lambda Functions
```hcl
# Lambda environment variables
resource "aws_lambda_function" "app" {
  # ... other configuration ...
  
  environment {
    variables = {
      DB_SECRET_ARN = module.database.secrets_manager_secret_arn
    }
  }
}
```

---

## 🏗️ Advanced Configuration

### Custom Parameters
```hcl
module "database" {
  # ... basic configuration ...
  
  custom_parameters = [
    {
      name  = "shared_preload_libraries"
      value = "pg_stat_statements,auto_explain"
    },
    {
      name  = "log_min_duration_statement"
      value = "500"  # Log queries slower than 500ms
    },
    {
      name  = "auto_explain.log_min_duration"
      value = "1000"
    }
  ]
}
```

### Production Hardening
```hcl
module "database" {
  # ... basic configuration ...
  
  # Production security settings
  deletion_protection         = true
  skip_final_snapshot        = false
  backup_retention_period    = 30
  performance_insights_enabled = true
  monitoring_interval        = 15  # More frequent monitoring
  
  # Multi-AZ for high availability
  multi_az = true
  
  # Enhanced logging
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  cloudwatch_log_retention_days   = 30
}
```
