{
      "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${ecs_log_group}",
        "awslogs-region": "eu-west-2",
        "awslogs-stream-prefix": "${logs_prefix}"
      }
    }
  }