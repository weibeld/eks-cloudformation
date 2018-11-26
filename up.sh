#!/bin/bash

set -e

# EDIT THIS:
#------------------------------------------------------------------------------#
NUM_WORKER_NODES=3
WORKER_NODES_INSTANCE_TYPE=t2.micro
STACK_NAME=test-cluster
KEY_PAIR_NAME=qs-us-east-1
#------------------------------------------------------------------------------#

# Output colours
COL='\033[1;34m'
NOC='\033[0m'

echo -e  "$COL> Deploying CloudFormation stack (may take up to 15 minutes)...$NOC"
aws cloudformation deploy \
  "$@" \
  --template-file eks.yml \
  --capabilities CAPABILITY_IAM \
  --stack-name "$STACK_NAME" \
  --parameter-overrides \
      KeyPairName="$KEY_PAIR_NAME" \
      NumWorkerNodes="$NUM_WORKER_NODES" \
      WorkerNodesInstanceType="$WORKER_NODES_INSTANCE_TYPE"

echo -e "\n$COL> Updating kubeconfig file...$NOC"
aws eks update-kubeconfig "$@" --name "$STACK_NAME" 

echo -e "\n$COL> Configuring worker nodes (to join the cluster)...$NOC"
# Get worker nodes role ARN from CloudFormation stack output
arn=$(aws cloudformation describe-stacks \
  "$@" \
  --stack-name "$STACK_NAME" \
  --query "Stacks[0].Outputs[?OutputKey=='WorkerNodesRoleArn'].OutputValue" \
  --output text)
# Enable worker nodes to join the cluster:
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

echo -e "\n$COL> Almost done! Cluster will be ready when all nodes have a 'Ready' status."
echo -e "> Check it with: kubectl get nodes --watch$NOC"
