variable "cidr_vpc" {
    type = string
    default = "10.0.0.0/16"
}

variable "environment" {
    type = string
    default = "dev"
}

variable "public_subnet_a" {
    type = list
    default = ["10.0.128.0/20"]
}

variable "public_subnet_b" {
    type = list
    default = ["10.0.144.0/20"]
}

variable "privat_subnet_a" {
    type = list
    default = ["10.0.0.0/19"]
}

variable "privat_subnet_b" {
    type = list
    default = ["10.0.32.0/19"]
}

variable "az_a" {
    type = string
    default = "eu-west-3a"
}

variable "az_b" {
    type = string
    default = "eu-west-3b"
}
