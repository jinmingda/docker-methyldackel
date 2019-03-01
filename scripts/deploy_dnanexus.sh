#!/bin/bash
set -e -x

#VERSION_APPLET="$(awk '$2 == "VERSION" { print $3; exit }' Dockerfile)"
VERSION_APPLET=$TRAVIS_TAG
dx mkdir -p $IMAGE/$VERSION_APPLET
dx cd $IMAGE/$VERSION_APPLET

dx build dnanexus/$IMAGE --archive

dx upload dnanexus/$IMAGE/test/ -r -p --no-progress --brief --destination ./test/
dx run ./$IMAGE --verbose -y --wait --watch --destination ./test/ \
    -ibamfile_link=./test/sample.bam \
    -iref_genome_link=./test/reference.fa.gz \
    -iaws_access_key_id=$AWS_ACCESS_KEY_ID \
    -iaws_secret_access_key=$AWS_SECRET_ACCESS_KEY
dx rm -r test  # dx run input is configurable and return 0 regardless of job result

