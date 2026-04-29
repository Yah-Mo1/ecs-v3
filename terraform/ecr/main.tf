# Create ECR repositories for the services
resource "aws_ecr_repository" "ecr_repositories" {
  for_each = toset(var.service_names)
  name = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = var.environment
    Region = var.region
    Project = var.project_name
  }

  
}
