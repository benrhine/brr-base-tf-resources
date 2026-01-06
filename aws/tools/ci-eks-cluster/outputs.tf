
output "vpc_id" {
  value = data.aws_vpc.custom.id
}

output "public_subnets" {
  value = data.aws_subnets.public.ids
}

output "private_subnets" {
  value = data.aws_subnets.private.ids
}