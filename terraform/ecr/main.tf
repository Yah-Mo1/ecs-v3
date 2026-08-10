# Create ECR repositories for the services

data "aws_ecr_repository" "ecr_repositories" {
  for_each = toset(var.service_names)
  name = each.value
}