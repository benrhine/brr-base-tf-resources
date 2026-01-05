
output "vpc_id" {
  value = data.aws_vpc.custom.id
}

output "private_subnets" {
  value = data.aws_subnets.private.ids
}