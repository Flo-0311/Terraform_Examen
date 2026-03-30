variable "environment" {
  type = string
}

variable "cidr_vpc" {
    type = string
    description = "VPC's CIDR Examen Liora"
    default = "10.0.0.0/16"
}

variable "public_subnets" {
  type = map(string)

  default = {
    a = "10.0.128.0/20"
    b = "10.0.144.0/20"
  }
}


variable "privat_subnets" {
  type = map(string)

  default = {
    a = "10.0.0.0/19"
    b = "10.0.32.0/19"
  }
}