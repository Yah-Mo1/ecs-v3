module "vpc" {
  source         = "./modules/network"
  project_name   = var.project_name
  environment    = var.environment
  vpc_cidr_block = var.vpc_cidr_block
  tags           = local.common_tags
}


//ECS Module - depends on RDS, Secrets Manager, and SQS