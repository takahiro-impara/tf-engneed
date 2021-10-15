variable "tagNames" {

}

variable "name" {

}

variable "server_port" {

}

variable "cidr_blocks" {

}

variable "protocol" {

}

variable "vpc_id" {

}
resource "aws_security_group" "instance" {
  name   = var.name
  tags   = var.tagNames
  vpc_id = var.vpc_id
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = var.protocol
    cidr_blocks = var.cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 追加
  lifecycle {
    create_before_destroy = true
  }
}
