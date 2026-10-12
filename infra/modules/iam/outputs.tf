output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "rds_and_sqs_ecs_task_role_arn" {
  value = aws_iam_role.rds_and_sqs_ecs_task_role.arn
}