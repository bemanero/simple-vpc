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

variable "Prod-pub-sub1_cidr_block" {

  description   = "subnet cidr_block"
  default       = "10.0.1.0/24"
}

variable "Prod-pub-sub2_cidr_block" {

  description   = "subnet cidr_block"
  default       = "10.0.2.0/24"
}

variable "Prod-priv-sub1_cidr_block" {

  description   = "subnet cidr_block"
  default       = "10.0.3.0/24"
}

variable "prod-priv-sub2_cidr_block" {

  description   = "subnet cidr_block"
  default       = "10.0.4.0/24"
}

variable "traffic_route" {

  description   = "traffic route"
  default       = "local"
}

variable "public_traffic_route" {

  description   = "public traffic"
  default       = "0.0.0.0/0"

}