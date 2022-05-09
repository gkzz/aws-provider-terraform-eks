output "cluster-name" {
  value = aws_eks_cluster.cluster.name
}

output "endpoint" {
  value     = aws_eks_cluster.cluster.endpoint
  sensitive = true
}

output "kubeconfig-certificate-authority-data" {
  value     = aws_eks_cluster.cluster.certificate_authority[0].data
  sensitive = true
}

# Only available on Kubernetes version 1.13 and 1.14 clusters created or upgraded on or after September 3, 2019.
output "identity-oidc-issuer" {
  value = data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}
