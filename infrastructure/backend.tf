# terraform s3 remote backend file
terraform {
  backend "s3" {
    bucket       = "remote-backend-state-for-terraform"
    key          = "nodejs-simpleapi/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }
}

