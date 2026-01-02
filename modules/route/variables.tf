

variable "vpc_id" {
  type = string
}


variable "public_subnet_ids"{
    type = map(string)
}

# variable "private_subnet_ids" {
#   type = map(string)
# }

variable "igw_id" {
  type = string
}

# variable "nat_id"{
#   type = string
# }

# variable "nat_network_interface_id"{
#   type = string
# }