variable "instance_type" {

}

variable "image_id" {

}

variable "user_data" {

}

variable "security_groups" {

}

variable "min_size" {

}

variable "max_size" {

}

variable "tagNames" {

}

variable "azs" {

}

variable "launch_name" {

}

variable "alb_target_group_arn" {

}

variable "topic_arn" {

}
resource "aws_launch_template" "this" {
  name_prefix            = var.launch_name
  image_id               = var.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = var.security_groups
  user_data              = filebase64(var.user_data)
  tags                   = var.tagNames
}

resource "aws_autoscaling_group" "this" {
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.azs

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
  force_delete      = true
  health_check_type = "ELB"
  target_group_arns = [var.alb_target_group_arn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "cpu" {
  name                   = "${var.tagNames["Name"]}-cpuscale"
  scaling_adjustment     = 6
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.this.name
}

resource "aws_autoscaling_notification" "this" {
  group_names = [
    aws_autoscaling_group.this.name
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]

  topic_arn = var.topic_arn
}
