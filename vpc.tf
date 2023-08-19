# Create VPC 
resource "aws_vpc" "TIG-VPC-TF" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "TIG-VPC-TF"
  }
}
# Create 2 public subnets

resource "aws_subnet" "Prod-pub-sub1" {
  vpc_id     = aws_vpc.TIG-VPC-TF.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Prod-pub-sub1"
  }
}

resource "aws_subnet" "Prod-pub-sub2" {
  vpc_id     = aws_vpc.TIG-VPC-TF.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Prod-pub-sub2"
  }
}



# Create 2 private subnets

resource "aws_subnet" "Prod-priv-sub1" {
  vpc_id     = aws_vpc.TIG-VPC-TF.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "Prod-priv-sub1"
  }
}

resource "aws_subnet" "prod-priv-sub2" {
  vpc_id     = aws_vpc.TIG-VPC-TF.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "prod-priv-sub2"
  }
}

# Create Public route table

resource "aws_route_table" "Prod-pub-route-table" {
  vpc_id = aws_vpc.TIG-VPC-TF.id

  # local traffic routed
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  /*# internet public traffic routed  (This is a way of routing traffic to the subnets but for this code, a aws_route will be provisioned to direct the traffic. line 137)
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Prod-igw.id
  }*/


  # This is used to route traffic from IPv6 addresses
  /*route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  }
*/
  tags = {
    Name = "Prod-pub-route-table"
  }
}



# Create private route table with local traffic routed

resource "aws_route_table" "Prod-priv-route-table" {
  vpc_id = aws_vpc.TIG-VPC-TF.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  /*# Traffic allowed from nat gateway (This is a way of routing traffic to the subnets but for this code, a aws_route will be will be provisioned to direct the traffic. line 171)
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.Prod-Nat-gateway.id
  }*/


  tags = {
    Name = "Prod-priv-route-table"
  }
}

# Create associations between subnets and corresponding route table

resource "aws_route_table_association" "PUB-SUB1-rta" {
  subnet_id      = aws_subnet.Prod-pub-sub1.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}

resource "aws_route_table_association" "PUB-SUB2-rta" {
  subnet_id      = aws_subnet.Prod-pub-sub2.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}

resource "aws_route_table_association" "PRIVATE-SUB1-rta" {
  subnet_id      = aws_subnet.Prod-priv-sub1.id
  route_table_id = aws_route_table.Prod-priv-route-table.id
}

resource "aws_route_table_association" "PRIVATE-SUB2-rta" {
  subnet_id      = aws_subnet.prod-priv-sub2.id
  route_table_id = aws_route_table.Prod-priv-route-table.id
}

# Create internet gateway

resource "aws_internet_gateway" "Prod-igw" {
  vpc_id = aws_vpc.TIG-VPC-TF.id

  tags = {
    Name = "Prod-igw"
  }
}


# Create associations between internet gateway and corresponding route table

resource "aws_route" "Prod-igw-association" {
  
    route_table_id          = aws_route_table.Prod-pub-route-table.id
    destination_cidr_block  = "0.0.0.0/0"
    gateway_id              = aws_internet_gateway.Prod-igw.id
    
    
    depends_on              = [aws_internet_gateway.Prod-igw]
}


# Create elastic IP to mask where traffic is requested from from a private subnet instance.
resource "aws_eip" "nat-eip" {

  depends_on = [aws_internet_gateway.Prod-igw]
}

# Create nat gateway from secure internet traffic to the private subnets

resource "aws_nat_gateway" "Prod-Nat-gateway" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.Prod-pub-sub1.id

  tags = {
    Name = "Prod-Nat-gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.Prod-igw]
}

# This is to route traffic to the correct path
resource "aws_route" "Prod-Nat-association" {
 
  route_table_id          = aws_route_table.Prod-priv-route-table.id
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = aws_nat_gateway.Prod-Nat-gateway.id

  depends_on              = [aws_route_table.Prod-priv-route-table]
}

# The end :)