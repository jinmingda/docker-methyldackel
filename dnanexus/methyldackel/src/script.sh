#!/bin/bash

main() {

  # set -x to print trace
  set -e -x

  opts=""

  mkdir -p /data/

  bamfile_name=`dx describe "$bamfile_link" --name`
  bedfile_name=${bamfile_name%.bam}_CpG.bedGraph

  dx download "$bamfile_link" -o /data/${bamfile_name}

  ref_genome_name=`dx describe "$ref_genome_link" --name`

  if [[ $ref_genome_name =~ \.gz$ ]]; then
    dx download "$ref_genome_link" -o /data/reference.fa.gz
    gunzip /data/reference.fa.gz
  else 
    dx download "$ref_genome_link" -o /data/reference.fa
  fi

  if [ -n "$ref_index_link" ]; then
    dx download "$ref_index_link" -o /data/reference.fa.fai
  fi

  if [ -n "$regionfile_link" ]; then
    dx download "$regionfile_link" -o /data/regions.bed
    opts="$opts -l regions.bed"
  fi

  if [ "$extra_options" != "" ]; then
    opts="$opts $extra_options"
  fi

  # login to pull images from ECR
  eval $(docker run --rm -e AWS_ACCESS_KEY_ID="$aws_access_key_id" -e AWS_SECRET_ACCESS_KEY="$aws_secret_access_key" mesosphere/aws-cli ecr get-login --no-include-email --region us-east-1)

  # for sandbox only, will skip in production
  if [ -f ~/methyldackel.tar ]; then
    docker load -i ~/methyldackel.tar
  fi

  docker run -v /data/:/tmp 002226384833.dkr.ecr.us-east-1.amazonaws.com/methyldackel:0.3.0 extract reference.fa ${bamfile_name} ${opts}

  bedfile_link=`dx upload /data/${bedfile_name} --brief`
  dx-jobutil-add-output bedfile_link "$bedfile_link"
}
