

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = map(string)
}

variable "private_subnet_ids" {
  type = map(string)
}

variable "target_group_arn" {
  type = string
}

variable "db_username" {
  type = string
  sensitive = true
}

variable "db_password" {
  type = string
  sensitive = true
}

variable "db_name" {
  type = string
}

variable "db_endpoint" {
  type = string
  sensitive = true
}

variable "wildcard" {
    type = string
    default = "0.0.0.0/0"
}

variable "vpc_cidr" {
  type = string
}