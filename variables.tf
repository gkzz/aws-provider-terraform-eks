variable "aws_access_key" {
  default = null
}

variable "aws_secret_key" {
  default = null
}

variable "region" {
  default = "ap-northeast-1"
}

variable "prefix" {
  default = "dev"
}

variable "instance_types" {
  description = <<-EOT
    検証用なのでできるだけお金をかけないようにしている。
　　 大きいサイズは、t3.xlarge などがある。
    https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html#AvailableInstanceTypes
  EOT
  default     = ["t2.small", "t3.small", "t2.medium"]
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
