# Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "nodejs-simpleapi"
}

variable "app_port" {
  description = "Port on which the application listens"
  type        = number
  default     = 3000
}