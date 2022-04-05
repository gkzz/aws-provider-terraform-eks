output "cluster-name" {
  value = aws_eks_cluster.gkzz-dev-cluster.name
}

output "endpoint" {
  value     = aws_eks_cluster.gkzz-dev-cluster.endpoint
  sensitive = true
}

output "kubeconfig-certificate-authority-data" {
  value     = aws_eks_cluster.gkzz-dev-cluster.certificate_authority[0].data
  sensitive = true
}
