output "autoscalingGroupname" {
  value = aws_autoscaling_group.this.name
}

output "cpuscaleArn" {
  value = aws_autoscaling_policy.cpu.arn
}
