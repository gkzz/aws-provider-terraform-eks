# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster
# aws_eks_cluster.my_cluster:
resource "aws_eks_cluster" "cluster" {
  name                      = "${var.prefix}_cluster"
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  role_arn                  = aws_iam_role.cluster_role.arn
  # https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html
  version = "1.22"

  #    kubernetes_network_config {
  #        service_ipv4_cidr = "10.100.0.0/16"
  #    }

  timeouts {}

  vpc_config {
    security_group_ids      = [aws_security_group.sg.id]
    endpoint_private_access = false
    endpoint_public_access  = true
    public_access_cidrs = [
      "0.0.0.0/0",
    ]
    subnet_ids = [
      aws_subnet.subnet_public1a.id,
      aws_subnet.subnet_public1c.id
    ]

  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController
  ]

  tags = {
    Name = "${var.prefix}-cluster"
  }
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${var.prefix}_node_group"
  node_role_arn   = aws_iam_role.node_iam_role.arn
  subnet_ids = [
    aws_subnet.subnet_public1a.id,
    aws_subnet.subnet_public1c.id
  ]

  scaling_config {
    /*
    desired_size = 3
    max_size     = 5
    min_size     = 2
    */
    desired_size = var.node_scaling_config["desired_size"]
    max_size     = var.node_scaling_config["max_size"]
    min_size     = var.node_scaling_config["min_size"]
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  timeouts {}

  #update_config {
  #  max_unavailable = 2
  #}

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
  disk_size = 20
  # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html
  #instance_types = ["t3.medium"]
  instance_types = var.instance_types
  capacity_type  = var.capacity_type


  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.gkzz_dev_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    aws_launch_template.node_group_lt
  ]

  tags = {
    "eks/cluster-name" = aws_eks_cluster.cluster.name
    Name               = "${var.prefix}_node_group"
  }
}


# https://tf-eks-workshop.workshop.aws/600_extra_content/610-second-node-group/tf-files.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
resource "aws_launch_template" "node_group_lt" {
  name                   = "${var.prefix}_lt"
  vpc_security_group_ids = [aws_security_group.sg.id]
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.prefix}_lt"
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}
