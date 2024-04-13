variable "aws_region" {

  description   = "aws region"
  default       = "eu-west-2"
}

variable "tenancy_allocation" {

  description   = "instance tenancy"
  default       = "default"
}

variable "VPC_cidr_block" {

  description   = "VPC cidr_block"
  default       = "10.0.0.0/16"
}