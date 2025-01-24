variable "region" {
  description = "Enter the default region for the vpc"
  type        = string
}

variable "public_subnets" {
  description = "Enter the public subnets for the vpc"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "Enter the VPC cidr"
  type        = string
}




