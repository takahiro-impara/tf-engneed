variable "ami" {

}

variable "instance_type" {

}

variable "keyname" {

}

variable "subnet_id" {

}

variable "vpc_security_group_ids" {

}

variable "tagNames" {

}

variable "user_data" {

}
resource "aws_instance" "this" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.keyname
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.vpc_security_group_ids
  tags                        = var.tagNames
  associate_public_ip_address = "true"
  user_data                   = file(var.user_data)
}
