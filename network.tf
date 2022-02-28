# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc

resource "aws_vpc" "gkzz-dev-vpc" {
  assign_generated_ipv6_cidr_block = false
  cidr_block                       = "192.168.0.0/16"
  enable_classiclink               = false
  enable_classiclink_dns_support   = false
  enable_dns_hostnames             = true
  enable_dns_support               = true
  instance_tenancy                 = "default"
  tags = {
    Name = "${var.prefix}-vpc"
  }

}

resource "aws_subnet" "gkzz-dev-subnet-public1a" {
  vpc_id                  = aws_vpc.gkzz-dev-vpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = cidrsubnet(aws_vpc.gkzz-dev-vpc.cidr_block, 8, 0)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-subnet-public1a"
  }

}

# Error: error creating EKS Cluster (gkzz-dev-cluster): InvalidParameterException: Subnets specified must be in at least two different AZs
resource "aws_subnet" "gkzz-dev-subnet-public1c" {
  vpc_id                  = aws_vpc.gkzz-dev-vpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = cidrsubnet(aws_vpc.gkzz-dev-vpc.cidr_block, 8, 1)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-subnet-public1c"
  }

}

resource "aws_route_table" "gkzz-dev-rt" {
  vpc_id = aws_vpc.gkzz-dev-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gkzz-dev-igw.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "${var.prefix}-rt"
  }
}

resource "aws_main_route_table_association" "gkzz-dev-rt-association" {
  vpc_id         = aws_vpc.gkzz-dev-vpc.id
  route_table_id = aws_route_table.gkzz-dev-rt.id
}

resource "aws_internet_gateway" "gkzz-dev-igw" {
  vpc_id = aws_vpc.gkzz-dev-vpc.id

  tags = {
    Name = "${var.prefix}-rt-assosication"
  }
}

resource "aws_security_group" "gkzz-dev-sg" {
  name        = "${var.prefix}-sg"
  description = "Allow 80 and 8000"
  vpc_id      = aws_vpc.gkzz-dev-vpc.id
  #ingress {
  #  description = "Allow 443 from anywhere"
  #  from_port   = 443
  #  to_port     = 443
  #  protocol    = "tcp"
  #  cidr_blocks = ["0.0.0.0/0"]
  #}
  ingress {
    description = "Allow 80 from anywhere for redirection"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow 8000 from anywhere for redirection"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-sg"
  }
}


