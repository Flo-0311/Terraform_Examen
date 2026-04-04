variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}


variable "vpc_cidr" {
  type = string
}

variable "privat_ids" {
  type = map(string)
}

variable "sg_80" {
  type = string
}

variable "db_username" {
  type = string
  default = "user"
  sensitive = true
}

variable "db_password" {
  type = string
  default = "password"
  sensitive = true
}

variable "db_name" {
  type = string
  default = "wordpress_db"
}

variable "wildcard" {
    type = string
    default = "0.0.0.0/0"
}