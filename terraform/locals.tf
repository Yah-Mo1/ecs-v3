locals {
  project_name = var.project_name

  tags = {
    environment = var.environment
    region = var.region
  }

}