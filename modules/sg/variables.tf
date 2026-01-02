variable "vpc_id"{
    type=string
}



variable "public_subnet_ids"{
  type = map(string)
}

variable "public_subnet_cidrs" {
  type = map(string)
  default = {
    "private-subnet-a" = "192.168.108.64/26"
    "private-subnet-b" = "192.168.108.128/26"
  }
}
