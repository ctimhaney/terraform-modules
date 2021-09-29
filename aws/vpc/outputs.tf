output "vpc_id" {
  value = aws_vpc.main.id
}

output "external_subnets" {
  value = aws_subnet.external[*].id
}

output "internal_subnets" {
  value = aws_subnet.internal[*].id
}
# TODO need internal references!
