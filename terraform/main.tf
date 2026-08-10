module "vpc" {
  source = "./vpc"
  project_name = local.project_name
  environment = var.environment
  region = var.region
  vpc_cidr_block = var.vpc_cidr_block
}

// Adjust public and private subnet CIDR blocks based on the number of availability zones --> Lists instead of single CIDR blocks