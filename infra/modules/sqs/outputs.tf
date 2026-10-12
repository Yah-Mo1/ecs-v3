output "orders_queue_url" {
  description = "The URL of the orders queue"
  value       = aws_sqs_queue.orders_queue.url
}

output "order_dlq_url" {
  description = "The URL of the order DLQ"
  value       = aws_sqs_queue.order_dlq.url
}