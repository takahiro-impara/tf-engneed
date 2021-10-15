variable "vpc_cidr" {

}

variable "tagNames" {

}

variable "public_subnets" {

}
variable "private_subnets" {

}
variable "secure_subets" {

}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  tags                 = var.tagNames
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "public" {
  for_each          = (var.public_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value["cidr"]
  availability_zone = each.value["az"]
  tags              = var.tagNames
}
resource "aws_subnet" "private" {
  for_each          = (var.private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value["cidr"]
  availability_zone = each.value["az"]
  tags              = var.tagNames
}
resource "aws_subnet" "secure" {
  for_each          = (var.secure_subets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value["cidr"]
  availability_zone = each.value["az"]
  tags              = var.tagNames
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = var.tagNames
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route" "this" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.this.id
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each       = (var.public_subnets)
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.this.id
}
