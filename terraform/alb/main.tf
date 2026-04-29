#Create the Application Load Balancer

locals {
    lb_name = "${var.project_name}-${var.environment}-alb"
    sg_name = "${var.project_name}-${var.environment}-alb-sg"
    tg_name = "${var.project_name}-${var.environment}-alb-tg"
}

#Create the Security group for the ALB

resource "aws_security_group" "alb_sg" {
    name        = local.sg_name
    description = "Security group for the ALB"
    vpc_id      = var.vpc_id
    
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_lb" "main" {
  name               = local.lb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [for subnet in var.public_subnet_ids : subnet]

  enable_deletion_protection = false

#   access_logs {
#     bucket  = aws_s3_bucket.lb_logs.id
#     prefix  = "test-lb"
#     enabled = true
#   }

  tags = {
    Environment = "production"
  }
}

#Create the Target Group for the ALB
resource "aws_lb_target_group" "ecs_tg" {
 name        = local.tg_name
 port        = 80
 protocol    = "HTTP"
 target_type = "ip"
 vpc_id      = var.vpc_id

 health_check {
   path = "/"
 }
}


#Create the HTTPS Listener for the ALB

resource "aws_lb_listener" "HTTPS" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}

# Create the HTTP Listener for the ALB

resource "aws_lb_listener" "HTTP" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Create the ACM Certificate for the ALB


resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Environment = var.environment
    Region      = var.region
    Project     = var.project_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

