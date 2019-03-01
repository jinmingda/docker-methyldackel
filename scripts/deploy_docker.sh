#!/bin/bash
set -e -x

pip install awscli
VERSION_CONTAINER="$(awk '$2 == "VERSION" { print $3; exit }' Dockerfile)"
# AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY must be set in travis
eval $(aws ecr get-login --no-include-email --region us-east-1)
docker tag $IMAGE:latest $ECR/$IMAGE:$VERSION_CONTAINER
docker tag $IMAGE:latest $ECR/$IMAGE:latest

docker push $ECR/$IMAGE:$VERSION_CONTAINER
docker push $ECR/$IMAGE:latest

