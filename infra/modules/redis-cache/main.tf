locals {
  redis_cache_name = "${var.project_name}-${var.environment}-redis-cache"
  tags = {
    environment = var.environment
    region      = var.region
  }

}


resource "aws_cloudwatch_log_group" "redis_cache_log_group" {
  name = "${var.project_name}-${var.environment}-redis-cache-log-group"
  retention_in_days = 30
  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-redis-cache-log-group"
  })
}

//Subnet group for the redis cache
resource "aws_elasticache_subnet_group" "redis_cache_subnet_group" {
  name = "${var.project_name}-${var.environment}-redis-cache-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-redis-cache-subnet-group"
  })
}


resource "aws_elasticache_cluster" "redis_cache" {
  cluster_id           = locals.redis_cache_name
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port                 = 6379

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_cache_log_group.name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }

  tags = merge(var.tags, {
    Name = local.redis_cache_name
  })
}
