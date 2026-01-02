variable "instance_type" {
  type        = string
  default     = "t3.small"  
}
variable "instance_class" {
  type        = string
  default     = "db.t3.micro"  
}
variable "db_username" {
  type        = string
  default     = "admin"
}

variable "db_password" {
  type        = string
  sensitive   = true
}