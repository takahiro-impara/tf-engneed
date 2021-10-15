variable "AutoScalingGroupName" {

}

variable "alarm_actions" {

}
resource "aws_cloudwatch_metric_alarm" "autoscaling" {
  alarm_name          = "autoscaling_CPUutil"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"

  dimensions = {
    AutoScalingGroupName = var.AutoScalingGroupName
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = var.alarm_actions
}
