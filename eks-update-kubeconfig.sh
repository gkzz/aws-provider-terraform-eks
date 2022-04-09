#!/bin/bash
# https://stackoverflow.com/questions/51121136/the-connection-to-the-server-localhost8080-was-refused-did-you-specify-the-ri

set -euo pipefail

EKS_CLUSTER_NAME="gkzz_dev_cluster"
REGION="ap-northeast-1"

aws eks update-kubeconfig \
  --name $EKS_CLUSTER_NAME \
  --region $REGION
