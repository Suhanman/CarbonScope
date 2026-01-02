


variable "db_subnet_ids_list" {
  type = list(string)
}


variable "rds_sg_id" {
  type = string
}



variable "instance_class" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}