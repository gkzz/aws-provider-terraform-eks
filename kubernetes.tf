data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.cluster.id
}
data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.cluster.id
}
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args = [
      "eks", "get-token",
      "--cluster-name", aws_eks_cluster.cluster.name,
      "--region", var.region
    ]
    command = "aws"
  }
}

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding
resource "kubernetes_cluster_role_binding" "cluster" {
  metadata {
    name = "${var.prefix}_cluster"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "User"
    name      = "admin"
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "kube-system"
  }
  subject {
    kind      = "Group"
    name      = "system:masters"
    api_group = "rbac.authorization.k8s.io"
  }
}
