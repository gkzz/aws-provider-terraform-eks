# https://github.com/DNXLabs/terraform-aws-eks-cloudwatch-logs

module "cloudwatch_logs" {
  source = "git::https://github.com/DNXLabs/terraform-aws-eks-cloudwatch-logs.git?ref=0.1.4"

  enabled = true
  # default
  namespace = "aws-cloudwatch-logs"
  # default
  service_account_name = "aws-for-fluent-bit"

  cluster_name                     = aws_eks_cluster.cluster.name
  cluster_identity_oidc_issuer     = aws_eks_cluster.cluster.identity.0.oidc.0.issuer
  cluster_identity_oidc_issuer_arn = aws_iam_openid_connect_provider.cluster.arn
  worker_iam_role_name             = aws_iam_role.node_iam_role.name
  region                           = var.region
}

# https://github.com/osvaldotoja/eks-irsa/blob/a94673081e1ca38188b1736c0c0911eb6c8754d5/openid-connect.tf#L12
### External cli kubergrunt

# https://shepherdmaster.hateblo.jp/entry/2020/12/20/230038
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates.0.sha1_fingerprint]
  url             = aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}

resource "aws_iam_role" "eks_cloudwatch_logs_role" {
  name = "gkzz-dev-ga-role"
  assume_role_policy = templatefile("policies/oidc_assume_role_policy.json", {
    OIDC_ARN = aws_iam_openid_connect_provider.cluster.arn
    OIDC_URL = replace(aws_iam_openid_connect_provider.cluster.url, "https://", ""), NAMESPACE = "kube-system",
    SA_NAME  = "aws-node"
  })
}


output "eks_cloudwatch_logs_role_arn" {
  value = aws_iam_role.eks_cloudwatch_logs_role.arn
}

output "aws_iam_openid_connect_provider_arn" {
  value = aws_iam_openid_connect_provider.cluster.arn
}
