locals {
  github_owner = "gkzz"
  github_repo  = "aws-provider-terraform-eks"
}

data "http" "github_actions_openid_configuration" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

data "tls_certificate" "github_actions" {
  url = jsondecode(data.http.github_actions_openid_configuration.body).jwks_uri
}

resource "aws_iam_openid_connect_provider" "openid-provider-ga" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]
}

resource "aws_iam_role" "gkzz-dev-ga-role" {
  name = "gkzz-dev-ga-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.openid-provider-ga.id}"
      },
      "Condition": {
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:${local.github_owner}/${local.github_repo}:*"
        }
      },
      "Action": "sts:AssumeRoleWithWebIdentity"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "gkzz-dev-iam-role-policy" {
  name = "gkzz-dev-iam-role-policy"
  role = aws_iam_role.gkzz-dev-ga-role.id
  /*
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ecr:GetAuthorizationToken",
            "Resource": "*"
        },
        {
            "Sid": "PushImageOnly",
            "Effect": "Allow",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:PutImage"
            ],
            "Resource": "arn:aws:ecr:ap-northeast-1:${var.aws_account_id}:repository/${var.ecr_repository_name}"
        }
    ]
}
EOF
}
*/

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        },
        {
            "Sid": "DenyIamOnly",
            "Effect": "Deny",
            "Action": [
                "iam:AddUserToGroup",
                "iam:RemoveUserFromGroup",
                "iam:UpdateUser",
                "iam:PutUserPermissionsBoundary",
                "iam:PutUserPolicy",
                "iam:DeleteUserPolicy",
                "iam:AttachUserPolicy",
                "iam:DeleteUser",
                "iam:DeleteUserPermissionsBoundary",
                "iam:DetachUserPolicy",
                "iam:CreateUser"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


output "gkzz-dev-ga-role-arn" {
  value = aws_iam_role.gkzz-dev-ga-role.arn
}

output "openid-provider-ga-thumbprint" {
  value = aws_iam_openid_connect_provider.openid-provider-ga.thumbprint_list
}
