locals {
  service_log_group_name = "${var.project_name}-${var.environment}-ecs-service-log-group"
  service_connect_log_group_name = "${var.project_name}-${var.environment}-service-connect-log-group"
}

resource "aws_cloudwatch_log_group" "service_log_group" {
  for_each = toset(var.service_names)
  name     = "${local.service_log_group_name}-${each.value}"
  tags = {
    Environment = var.environment
    Region      = var.region
    Project     = var.project_name
  }
}


resource "aws_cloudwatch_log_group" "service_connect_log_group" {
  for_each = toset(var.service_names)
  name     = "${var.project_name}-${var.environment}-service-connect-log-group-${each.value}"
  tags = {
    Environment = var.environment
    Region      = var.region
    Project     = var.project_name
  }
}

# We can look into also setting up some metrics on cloudwatch as well to capture specific logs 
# And perphaps you can do some alerting on those metrics as well. For example, if the number of errors exceeds a certain threshold, we can trigger an alert to notify the team. This can be done using CloudWatch Alarms and SNS topics for notifications.