# Create an SQS queue for the application 

resource "aws_sqs_queue" "orders_queue" {
  name = "orders-queue"

  visibility_timeout_seconds = 60
  message_retention_seconds = 345600
  delay_seconds = 0
  receive_wait_time_seconds = 20
  
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.order_dlq.arn
    maxReceiveCount     = 5
  })

  tags = merge(var.tags, {
    Name = "order-queue-${var.environment}"
  })
}


# Dead letter queue
resource "aws_sqs_queue" "order_dlq" {
  name                       = "order-dlq-${var.environment}"
  message_retention_seconds  = 1209600  # 14 days

  tags = merge(var.tags, {
    Name = "order-dlq-${var.environment}"
  })
}