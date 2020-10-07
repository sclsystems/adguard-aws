variable "aws_region" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "alternative_domain_names" {
  type = list(string)
}

variable "instance_type" {
  type = string
}

variable "admin_password_hash" {
  type = string
}

variable "allowed_client" {
  type = string
}

variable "subnet_list" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}
