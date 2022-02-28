# AWS Provider with Terraform (AWS EKS)
**This is an `experimental` repository to familiarize myself with Terraform/AWS EKS**.

## TL;DR
```
$ cp terraform.tfvars.tmpl terraform.tfvars
$ terraform init
$ terraform apply

$ terraform output -json

## update ${HOME}/.kube/config
$ ./eks-update-kubeconfig.sh
```

---

The following is only one example of EKS

## Deploy Argo CD
- [argocd.d/setup.md](./argocd.d/setup.md)

## Memo 
```
## Dry run
$ terraform plan

## Delete all resources
$ terraform destroy

## Display <dest-server of dev app registered with argocd command>
$ argocd cluster list
SERVER
https://xxxxxxxxxx.gr7.ap-northeast-1.eks.amazonaws.com
```

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html

Coming soon

- How to make pipeline with EKS/Github Actions/Argo CD, and more
