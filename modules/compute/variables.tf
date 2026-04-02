

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = map(string)
}

variable "wildcard" {
    type = string
    default = "0.0.0.0/0"
}

variable "var_cidr" {
  type = string
}





variable "db_endpoint" {
  description = "RDS database endpoint"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}