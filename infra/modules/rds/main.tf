#Plan:
# Create a RDS database for the application using the latest PostgreSQL version
# Create a RDS database for the application
# Use the latest PostgreSQL version
# Use the smallest instance type
# Use the smallest storage size
# Use the smallest instance class
# Use the smallest instance familys
# Use the smallest instance generation
# Use the smallest instance family

locals {
  database_instance_name = "${var.project_name}-${var.environment}-database-instance"
  database_subnet_group_name = "${var.project_name}-${var.environment}-database-subnets"
  tags = {
    environment = var.environment
    region      = var.region
  }
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}


# create database subnet group
resource "aws_db_subnet_group" "database_subnet_group" {
  name        = local.database_subnet_group_name
  subnet_ids  = var.private_subnet_ids
  description = "subnets for database instance"
  tags = merge(locals.tags, {
    Name = local.database_subnet_group_name
  })
}

# create the rds instance
resource "aws_db_instance" "database_instance" {
  engine                 = "postgres"
  engine_version         = "14"
  multi_az               = yes
  identifier             = var.database_instance_identifier //the name of the database instance
  username               = var.db_user
  password               = random_password.db_password.result
  db_name                = var.db_name
  instance_class         = var.database_instance_class
  allocated_storage      = 100
  db_subnet_group_name   = aws_db_subnet_group.database_subnet_group.name
  vpc_security_group_ids = [aws_security_group.database_security_group.id]
  availability_zone      = data.aws_availability_zones.available_zones.names[0]
  skip_final_snapshot    = true
  publicly_accessible    = false
  backup_retention_period = 7
  backup_target          = "region"
  backup_window          = "02:00-06:00"
  custom_iam_instance_profile = "ecs-instance-profile" //TODO: Create this IAM profile
  tags = merge(locals.tags, {
    Name = local.database_instance_name
  })
}



//TODO: Create a security group for the RDS instance to allow access from the ECS tasks
resource "aws_security_group" "database_security_group" {
  name        = "${var.project_name}-${var.environment}-database-security-group"
  description = "security group for database instance"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_id] //security group referenceing linking one security group to another
    description = "allow access from the ECS tasks"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-database-security-group"
  }
}