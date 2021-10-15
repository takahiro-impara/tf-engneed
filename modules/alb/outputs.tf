output "alb_target_group_arn" {
  value = aws_lb_target_group.ec2_http.arn
}
output "alb_target_group_arn_manage" {
  value = aws_lb_target_group.manage.arn
}

output "alb" {
  value = aws_lb.this
}
