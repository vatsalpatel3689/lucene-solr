#!/bin/bash
set -e
VERSION=$1
IMAGETAG=$2

#Defining constant variables for image repo and host
readonly IMAGEREPO="fk-neo-solr"
readonly DOCKERHUB="10.47.7.214"

#Build the docker image
docker build -t=$DOCKERHUB/$IMAGEREPO:$IMAGETAG  --build-arg VERSION=$VERSION .

#Push the docker image to the central image repo
docker push $DOCKERHUB/$IMAGEREPO:$IMAGETAG