provider "helm" {
  # https://github.com/hashicorp/terraform-provider-helm/issues/400
  /*
  kubernetes {
    config_path = "~/.kube/config"
  }
  */
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    #load_config_file       = false
    exec {
      # https://stackoverflow.com/questions/71318743/kubectl-versions-error-exec-plugin-is-configured-to-use-api-version-client-auth
      api_version = "client.authentication.k8s.io/v1alpha1"
      #api_version = "client.authentication.k8s.io/v1beta1"
      args = [
        "eks", "get-token",
        "--cluster-name", aws_eks_cluster.cluster.name,
        "--region", var.region
      ]
      command = "aws"
    }
  }
}

/*
data "aws_eks_cluster_auth" "cluster-auth" {
  depends_on = [aws_eks_cluster.cluster]
  name       = aws_eks_cluster.cluster.name
}
*/
