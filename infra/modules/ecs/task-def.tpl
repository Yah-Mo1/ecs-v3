[
  {
    "name": "${container_name}",
    "image": "${image}",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "environment": "${environment}",
    "portMappings": [
      {
        "containerPort": ${container_port},
        "hostPort": ${host_port},
        "protocol": "tcp"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "ecs-${container_name}"
      }
    }
  }
]