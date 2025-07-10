Here’s a clean and professional `README.md` for your reusable VPC Terraform module:

---

## 🌐 VPC Terraform Module

This module provisions a production-ready **AWS Virtual Private Cloud (VPC)** with:

- Dynamically generated **public and private subnets** in all available AZs of the region
- **Internet Gateway** for public subnet access
- Route tables and subnet associations
- Tagging support

---

## 📁 Features

- ✅ Highly available (1 subnet per AZ)
- ✅ Automatically determines available AZs
- ✅ Clean resource naming via `name_prefix`
- ✅ Outputs for integrating with other modules

---

## 📦 Usage

### Module Structure

```
vpc-module/
├── main.tf
├── variables.tf
├── outputs.tf
```

### Minimal Example

```hcl
provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source                   = "../vpc-module"
  name_prefix              = "main-vpc"
  vpc_cidr                 = "10.1.0.0/16"
  public_subnet_cidr_bits  = 8
  private_subnet_cidr_bits = 8
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
```

---

## 🔧 Inputs

| Name                    | Description                                | Type   | Default       | Required |
|-------------------------|--------------------------------------------|--------|---------------|----------|
| `name_prefix`           | Prefix used for resource naming            | string | n/a           | ✅ Yes   |
| `vpc_cidr`              | CIDR block for the VPC                     | string | `"10.0.0.0/16"`| ❌ No    |
| `public_subnet_cidr_bits` | New bits for public subnetting          | number | `8`           | ❌ No    |
| `private_subnet_cidr_bits`| New bits for private subnetting         | number | `8`           | ❌ No    |

---

## 📤 Outputs

| Name               | Description                            |
|--------------------|----------------------------------------|
| `vpc_id`           | ID of the created VPC                  |
| `public_subnet_ids`| List of public subnet IDs              |
| `private_subnet_ids`| List of private subnet IDs            |

---

## 🧠 How Subnets Are Calculated

Terraform uses `cidrsubnet()` to split the VPC range into subnets:

```hcl
cidrsubnet(var.vpc_cidr, var.public_subnet_cidr_bits, count.index)
```

If `vpc_cidr = 10.0.0.0/16` and `public_subnet_cidr_bits = 8`, then:

- AZ 1 public subnet → `10.0.0.0/24`
- AZ 2 public subnet → `10.0.1.0/24`
- AZ 3 public subnet → `10.0.2.0/24`

---

## ✅ Requirements

- Terraform ≥ 1.0
- AWS credentials configured (e.g. via `~/.aws/credentials` or env vars)