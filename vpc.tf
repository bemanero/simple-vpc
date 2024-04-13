# Create VPC 
resource "aws_vpc" "TIG-VPC-TF" {
  cidr_block       = var.VPC_cidr_block
  instance_tenancy = var.tenancy_allocation

  tags = {
    Name = "TIG-VPC-TF"
  }
}