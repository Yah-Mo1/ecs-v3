output "service_log_groups_names" {
  description = "The names of the CloudWatch log groups for the ECS services"
  value       = [for log_group in aws_cloudwatch_log_group.service_log_group : log_group.name]
}

output "service_connect_log_groups_names" {
  description = "The names of the CloudWatch log groups for the ECS services for service connect"
  value       = [for log_group in aws_cloudwatch_log_group.service_connect_log_group : log_group.name]
}