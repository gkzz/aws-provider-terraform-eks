variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "aws_account_id" {}

variable "ecr_repository_name" {}

variable "region" {
  default = "ap-northeast-1"
}

variable "prefix" {
  default = "gkzz-dev"
}

variable "instance_types" {
  type    = list(string)
  default = ["t2.small", "t3.small", "t2.medium"]
  #default = ["t3.medium"]
}

variable "capacity_type" {
  default = "SPOT"
  #default = "ON_DEMAND"
}
