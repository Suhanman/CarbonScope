

output "public_subnet_ids" {
  value = {
    public-subnet-a = aws_subnet.public_subnet_ids["public-subnet-a"].id
    public-subnet-c = aws_subnet.public_subnet_ids["public-subnet-c"].id
  }
}
output "public_subnet_ids_list" {
  value = [
    aws_subnet.public_subnet_ids["public-subnet-a"].id,
    aws_subnet.public_subnet_ids["public-subnet-c"].id
  ]
}
output "db_subnet_ids_list" {
  value = [
    aws_subnet.db_subnet_ids["db-subnet-a"].id,
    aws_subnet.db_subnet_ids["db-subnet-c"].id
  ]
}