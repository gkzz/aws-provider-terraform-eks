variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "region" {
  default = "ap-northeast-1"
}

variable "prefix" {
  default = "gkzz-dev"
}

variable "instance_types" {
  type    = list(string)
  default = ["t2.small", "t3.small", "t2.medium"]
  #default = ["t3.xlarge", "t3.2xlarge"]
}

variable "capacity_type" {
  default = "SPOT"
  #default = "ON_DEMAND"
}

variable "node_scaling_config" {
  type = map(string)
  default = {
    desired_size = 3
    max_size     = 4
    min_size     = 2
  }
}
