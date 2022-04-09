output "cluster-name" {
  value = aws_eks_cluster.gkzz_dev_cluster.name
}

output "endpoint" {
  value     = aws_eks_cluster.gkzz_dev_cluster.endpoint
  sensitive = true
}

output "kubeconfig-certificate-authority-data" {
  value     = aws_eks_cluster.gkzz_dev_cluster.certificate_authority[0].data
  sensitive = true
}
