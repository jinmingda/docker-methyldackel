#!/bin/bash
set -e -x

if [ -n "$TRAVIS_TAG" ]; then
  # travis deploy on tags
  dx select $DX_PROJECT
  VERSION_APPLET=$TRAVIS_TAG
else
  # travis deploy on branch
  mkdir -p dnanexus/$IMAGE/resources/home/dnanexus/
  docker save $ECR/$IMAGE:$VERSION_CONTAINER -o dnanexus/$IMAGE/resources/home/dnanexus/$IMAGE.tar
  VERSION_APPLET=$(cat /proc/sys/kernel/random/uuid)
fi

dx mkdir -p $IMAGE/$VERSION_APPLET
dx cd $IMAGE/$VERSION_APPLET

dx build dnanexus/$IMAGE

dx upload dnanexus/$IMAGE/test/ -r -p --no-progress --brief --destination ./test/
dx run ./$IMAGE --verbose -y --wait --watch --destination ./test/ \
    -iaws_access_key_id=$AWS_ACCESS_KEY_ID \
    -iaws_secret_access_key=$AWS_SECRET_ACCESS_KEY \
    -ibamfile_link=./test/sample.bam \
    -iref_genome_link=./test/reference.fa.gz
# dx run input is configurable and will return 0 regardless of the job result

if [ -n "$TRAVIS_TAG" ]; then
  dx rm -r test
fi

