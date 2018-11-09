#!/bin/bash

STACK_NAME=eks-test
PARAM_KEY_PAIR_NAME=qs-master
PARAM_NUM_WORKER_NODES=3
PARAM_WORKER_NODES_INSTANCE_TYPE=t2.xlarge

aws cloudformation deploy \
  --template-file eks.yml \
  --capabilities CAPABILITY_IAM \
  --stack-name "$STACK_NAME" \
  --parameter-overrides \
      KeyPairName="$PARAM_KEY_PAIR_NAME" \
      NumWorkerNodes="$PARAM_NUM_WORKER_NODES" \
      WorkerNodesInstanceType="$PARAM_WORKER_NODES_INSTANCE_TYPE"
