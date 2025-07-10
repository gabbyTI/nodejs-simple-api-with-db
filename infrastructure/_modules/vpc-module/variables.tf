variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_bits" {
  description = "CIDR subnet bits for public subnets"
  type        = number
  default     = 8
}

variable "private_subnet_cidr_bits" {
  description = "CIDR subnet bits for private subnets"
  type        = number
  default     = 8
}
