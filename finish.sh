#!/bin/bash

set -e

STACK_NAME=eks-test

# Update ~/.kube/config (note: cluster name == stack name)
aws eks update-kubeconfig --name "$STACK_NAME"

# Get worker nodes role ARN
arn=$(aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --query "Stacks[0].Outputs[?OutputKey=='WorkerNodesRoleArn'].OutputValue" \
  --output text)

# Make worker nodes join the cluster:
# https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html#eks-create-cluster
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: $arn
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
EOF
