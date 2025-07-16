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
  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "Setting up Node.js environment"
    # Update package manager and install prerequisites
    apt update && apt install -y curl
    # Install Node.js
    curl -sL https://deb.nodesource.com/setup_23.x | bash -
    apt install -y nodejs
    # Install PM2 globally
    npm install -g pm2
    # Setup PM2 to start on boot
    pm2 startup systemd -u ubuntu --hp /home/ubuntu
    EOF
  )
}

module "alb" {
  source                 = "./_modules/alb"
  name_prefix = "${var.project_name}-${var.environment}"
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.vpc.public_subnet_ids
  security_groups        = [aws_security_group.app_alb.id]
  app_port               = var.app_port
  redirect_http_to_https = false
}

resource "aws_lb_target_group_attachment" "tg_attachment" {
  target_group_arn = module.alb.target_group_arn
  target_id        = module.app_server.instance_id
  port             = var.app_port
  
}
