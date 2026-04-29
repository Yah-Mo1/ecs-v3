output "ecr_repositories" {
  description = "The list of ECR repositories"
  value = aws_ecr_repository.ecr_repositories
}