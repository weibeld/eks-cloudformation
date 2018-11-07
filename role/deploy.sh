#!/bin/bash

aws cloudformation deploy \
  --template-file role.yml \
  --stack-name eks-service-role \
  --capabilities CAPABILITY_NAMED_IAM
