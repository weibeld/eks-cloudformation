#!/bin/bash

stack=$1
cmd=$2

if [[ -z "$stack" || -z "$cmd" ]]; then
  echo "Usage: stack.sh <stack-name> up|down"
  exit 1
fi

if [ "$cmd" = up ]; then
  aws cloudformation deploy --template-file eks.yml --stack-name "$stack" --capabilities CAPABILITY_IAM
else
  aws cloudformation delete-stack --stack-name "$stack"
fi
