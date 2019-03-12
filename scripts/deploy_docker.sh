#!/bin/bash
set -e -x

pip install awscli
eval $(aws ecr get-login --no-include-email --region us-east-1)
docker push $ECR/$IMAGE:$VERSION_CONTAINER
docker push $ECR/$IMAGE:latest

