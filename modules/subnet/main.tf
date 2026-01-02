# resource "aws_subnet" "public" {
#   vpc_id                  = var.vpc_id
#   cidr_block              = "192.168.108.0/26"
#   availability_zone       = "ap-northeast-2a"
#   map_public_ip_on_launch = true
#   tags = {
#     Name = "public-subnet"
#   }
# }


resource "aws_subnet" "public_subnet_ids" {
  for_each                = {
    public-subnet-a = { cidr = "192.168.108.0/26", az = "ap-northeast-2a" }
    public-subnet-c = { cidr = "192.168.108.64/26", az = "ap-northeast-2c" }
  }
  vpc_id     = var.vpc_id
  map_public_ip_on_launch = true
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = each.key
  }
}

resource "aws_subnet" "db_subnet_ids" {
  for_each                = {
    db-subnet-a = { cidr = "192.168.108.128/26", az = "ap-northeast-2a" }
    db-subnet-c = { cidr = "192.168.108.192/26", az = "ap-northeast-2c" }
  }
  vpc_id     = var.vpc_id
  map_public_ip_on_launch = false
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = each.key
  }
}