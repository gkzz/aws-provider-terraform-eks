output "cluster-name" {
  value = aws_eks_cluster.cluster.name
}

output "endpoint" {
  description = <<EOT
    Endpoint for your Kubernetes API server.
    https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster#attributes-reference
  EOT
  value       = aws_eks_cluster.cluster.endpoint
  sensitive   = true
}

output "kubeconfig-certificate-authority-data" {
  value     = aws_eks_cluster.cluster.certificate_authority[0].data
  sensitive = true
}
