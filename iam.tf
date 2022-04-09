resource "aws_iam_role" "gkzz_dev_cluster_role" {
  name = "gkzz_dev_cluster_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "gkzz_dev_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.gkzz_dev_cluster_role.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "gkzz_dev_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.gkzz_dev_cluster_role.name
}

resource "aws_iam_role" "gkzz_dev_node_role" {
  name = "gkzz_dev_node_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
resource "aws_iam_role_policy_attachment" "gkzz_dev_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.gkzz_dev_node_role.name
}

resource "aws_iam_role_policy_attachment" "gkzz_dev_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.gkzz_dev_node_role.name
}

resource "aws_iam_role_policy_attachment" "gkzz_dev_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.gkzz_dev_node_role.name
}

/*
# https://stackoverflow.com/questions/65890676/attaching-aws-managed-policy-to-a-custom-role-via-terraform
#Create Policy - Not Required as its an AWS Managed Policy
resource "aws_iam_policy" "CloudWatchAgentServerPolicy" {
  name        = "CloudWatchAgentServerPolicy"
  description = "Permissions required to use AmazonCloudWatchAgent on servers"
  policy      =  <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "ec2:DescribeVolumes",
                "ec2:DescribeTags",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams",
                "logs:DescribeLogGroups",
                "logs:CreateLogStream",
                "logs:CreateLogGroup"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*"
        }
    ]
}
POLICY
}*/

/*
# Attach CloudWatchAgentServerPolicy
resource "aws_iam_role_policy_attachment" "CloudWatchAgentServer" {
  role       = aws_iam_role.gkzz_dev_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
*/

# Attach CloudWatchLogsFullAccessPolicy
resource "aws_iam_role_policy_attachment" "CloudWatchLogsFullAccess" {
  role       = aws_iam_role.gkzz_dev_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
