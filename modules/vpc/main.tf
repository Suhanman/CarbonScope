resource "aws_vpc" "cloud4" {
  cidr_block       = "192.168.108.0/24"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name ="cloudproject-vpc"
  }
}

