#!/bin/bash

STACK_NAME=eks-test
PARAM_KEY_PAIR_NAME=qs-master

aws cloudformation deploy \
  --template-file eks.yml \
  --capabilities CAPABILITY_IAM \
  --stack-name "$STACK_NAME" \
  --parameter-overrides \
      KeyPairName="$PARAM_KEY_PAIR_NAME"
