variable "environment" {
  type = string
}


variable "wildcard" {
    type = string
    default = "0.0.0.0/0"
}



variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = map(string)
}

variable "vpc_cidr" {
  type = string
}