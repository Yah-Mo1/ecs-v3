output "alb_id" {
    value = aws_lb.main.id
    description = "The ID of the Load Balancer"
  
}

output "alb_sg" {
    value = aws_security_group.alb_sg.id
    description = "The ID of the Security Group for the Load Balancer"
  
}