#!/bin/bash

aws cloudformation deploy \
  --template-file eks.yml \
  --stack-name eks-test \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides KeyPairName=qs-master
