locals {
  secret_name = "${var.project_name}-${var.environment}-postgres-secrets"
  tags = {
    environment = var.environment
    region = var.region
  }
  
}

resource "aws_secretsmanager_secret" "postgres_secrets_manager" {
  name = locals.secret_name
  description = "Secrets for Postgres database"
  tags = local.tags
}


// Can we allow the ecs service to be able to read the secrets from the secrets manager?
//TODO: Research if this is possible.

data "aws_iam_policy_document" "ecs-secrets-manager-policy" {
  statement {
    sid    = "EnableAnotherAWSAccountToReadTheSecret"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::123456789012:root"]
    }

    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["*"]
  }
}




//What is the lambda Arn?
resource "aws_secretsmanager_secret_rotation" "postgres_secrets_rotation" {
  secret_id           = aws_secretsmanager_secret.postgres_secrets_manager.id
  # rotation_lambda_arn = aws_lambda_function.example.arn

  rotation_rules {
    automatically_after_days = 30
  }
}


//Secrets Version
//TODO: Look into this! -> 
resource "aws_secretsmanager_secret_version" "postgres_secrets_version" {
  secret_id     = aws_secretsmanager_secret.postgres_secrets_manager.id
  secret_string = "example-string-to-protect"
}