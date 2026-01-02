variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "public_subnet_ids"{
    type = map(string)
}

variable "app_key_name"{
    type = string
}

variable "ec2_sg_id"{
  type = string
}

variable "app_instance_profile" {
  type    = string
}
 