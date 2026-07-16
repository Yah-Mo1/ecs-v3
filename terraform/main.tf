module "vpc" {
  source = "./vpc"
  project_name = local.project_name
  environment = var.environment
  region = var.region
  vpc_cidr_block = "10.0.0.0/16"
  public_subnet_cidr_block = "10.0.1.0/24"
  private_subnet_cidr_block = "10.0.2.0/24"
}

// Adjust public and private subnet CIDR blocks based on the number of availability zones --> Lists instead of single CIDR blocks