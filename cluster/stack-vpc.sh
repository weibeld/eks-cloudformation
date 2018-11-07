#!/bin/bash

if [ "$1" = up ]; then
  aws cloudformation deploy --template-file vpc.yml --stack-name test-vpc
else
  aws cloudformation delete-stack --stack-name test-vpc
fi
