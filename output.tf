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
