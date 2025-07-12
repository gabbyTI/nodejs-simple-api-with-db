# Create VPC using the VPC module
module "vpc" {
  source = "./_modules/vpc-module"

  name_prefix              = "${var.project_name}-${var.environment}"
  vpc_cidr                 = "10.0.0.0/16"
  public_subnet_cidr_bits  = 8 # Creates /24 subnets (10.0.0.0/24, 10.0.1.0/24, etc.)
  private_subnet_cidr_bits = 8 # Creates /24 subnets (10.0.10.0/24, 10.0.11.0/24, etc.)
}

module "postgres_db" {
  source = "./_modules/rds-postgres-module"

  # Basic Configuration
  name_prefix        = "${var.project_name}-${var.environment}"
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = module.vpc.vpc_cidr
  private_subnet_ids = module.vpc.private_subnet_ids

  # Database Configuration
  database_name = "nodejs_app"
  db_username   = "app_user"
  # db_password    = "secure_password_123"  # Optional - if not provided, will be generated
  postgres_version = "16.4"
  instance_class   = "db.t3.micro"

  # Storage Configuration
  allocated_storage = 20
}

module "app_server" {
  source             = "./_modules/ec2-instance-with-static-eip"
  subnet_id          = module.vpc.public_subnet_ids[0] # Use the first public subnet for the instance
  name_prefix        = var.project_name
  security_group_ids = [aws_security_group.app.id]
  ami                = "ami-0ae6f07ad3a8ef182" # Replace with your AMI ID
  instance_type      = "t4g.micro"
  environment        = var.environment
}
