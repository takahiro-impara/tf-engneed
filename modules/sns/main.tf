variable "tagNames" {

}
resource "aws_sns_topic" "autoscaling" {
  name = "notify-terminate-autoscaling"
  tags = var.tagNames
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.autoscaling.arn
  protocol  = "email"
  endpoint  = "takahiro4120@gmail.com"
}

