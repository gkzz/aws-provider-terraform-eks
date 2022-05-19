# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc

resource "aws_vpc" "gkzz_dev_vpc" {
  assign_generated_ipv6_cidr_block = false
  cidr_block                       = "192.168.0.0/16"
  enable_classiclink               = false
  enable_classiclink_dns_support   = false
  enable_dns_hostnames             = true
  enable_dns_support               = true
  instance_tenancy                 = "default"
  tags = {
    Name = "${var.prefix}_vpc"
  }

}

resource "aws_subnet" "gkzz_dev_subnet_public1a" {
  vpc_id                  = aws_vpc.gkzz_dev_vpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = cidrsubnet(aws_vpc.gkzz_dev_vpc.cidr_block, 8, 0)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}_subnet_public1a"
  }

}

# Error: error creating EKS Cluster (gkzz-dev-cluster): InvalidParameterException: Subnets specified must be in at least two different AZs
resource "aws_subnet" "gkzz_dev_subnet_public1c" {
  vpc_id                  = aws_vpc.gkzz_dev_vpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = cidrsubnet(aws_vpc.gkzz_dev_vpc.cidr_block, 8, 1)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}_subnet_public1c"
  }

}

resource "aws_route_table" "gkzz_dev_rt" {
  vpc_id = aws_vpc.gkzz_dev_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gkzz_dev_igw.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "${var.prefix}_rt"
  }
}

resource "aws_main_route_table_association" "gkzz_dev_rt_association" {
  vpc_id         = aws_vpc.gkzz_dev_vpc.id
  route_table_id = aws_route_table.gkzz_dev_rt.id
}

resource "aws_internet_gateway" "gkzz_dev_igw" {
  vpc_id = aws_vpc.gkzz_dev_vpc.id

  tags = {
    Name = "${var.prefix}_rt_assosication"
  }
}

resource "aws_security_group" "gkzz_dev_sg" {
  name        = "${var.prefix}_sg"
  description = "Allow 80 and 8000"
  vpc_id      = aws_vpc.gkzz_dev_vpc.id
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
    description = "Allow 5000 from anywhere for redirection"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow 8125 from anywhere for dogstatsd"
    from_port   = 8125
    to_port     = 8125
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow 80 from anywhere for datadog.apm.port "
    from_port   = 8126
    to_port     = 8126
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
    Name = "${var.prefix}_sg"
  }
}


