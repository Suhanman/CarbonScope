resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
   for_each       = var.public_subnet_ids
  subnet_id      = each.value
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = var.vpc_id

  tags = {
    Name = "private-rt"
  }
}


# resource "aws_route" "private_nat_route" {
#   route_table_id         = aws_route_table.private_rt.id
#   destination_cidr_block = "0.0.0.0/0"
#   network_interface_id             = var.nat_network_interface_id
# }


# resource "aws_route_table_association" "private_assoc" {
#   for_each       = var.private_subnet_ids
#   subnet_id      = each.value
#   route_table_id = aws_route_table.private_rt.id
# }
