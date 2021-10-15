output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_ids" {
  value = values(aws_subnet.public)[*].id
}

output "private_ids" {
  value = values(aws_subnet.private)[*].id
}

output "secure_ids" {
  value = values(aws_subnet.secure)[*].id
}
