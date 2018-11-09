#!/bin/bash

# EDIT VARIABLE VALUES:
STACK_NAME=eks-test
PARAM_KEY_PAIR_NAME=qs-master
PARAM_NUM_WORKER_NODES=2
PARAM_WORKER_NODES_INSTANCE_TYPE=t2.xlarge

echo "Deploying CloudFormation stack (may take up to 15 minutes)..."
aws cloudformation deploy \
  --template-file eks.yml \
  --capabilities CAPABILITY_IAM \
  --stack-name "$STACK_NAME" \
  --parameter-overrides \
      KeyPairName="$PARAM_KEY_PAIR_NAME" \
      NumWorkerNodes="$PARAM_NUM_WORKER_NODES" \
      WorkerNodesInstanceType="$PARAM_WORKER_NODES_INSTANCE_TYPE"

echo "Updating kubeconfig file..."
aws eks update-kubeconfig --name "$STACK_NAME"

echo "Configuring worker nodes (to join the cluster)..."
# Get worker nodes role ARN from CloudFormation stack output
arn=$(aws cloudformation describe-stacks \
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

echo "Almost done! Cluster will be ready when all nodes have a 'Ready' status."
echo "Check it with: kubectl get nodes --watch"
