migration "state" "import_aws_iam_policy" {
  dir = "."
  actions = [
    "import aws_iam_policy.CloudWatchAgentServerPolicy arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
}