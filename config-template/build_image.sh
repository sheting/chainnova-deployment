#!/bin/bash

START=$(date +"%s")

#REPOSITORY & TAG & IMAGE
REPOSITORY="chainnova/config-template"
TAG="0.0.1"
IMAGE_LOCAL="$REPOSITORY:$TAG"

echo
echo "##############################"
echo "##### build image"
echo "##############################"
docker images | grep -q -E "^$REPOSITORY\s+$TAG\s+"
if [ $? == 0 ]; then
    echo "No need to rebuild $IMAGE_LOCAL"
    exit 0
fi

#build image
docker build -f ./docker/Dockerfile -t $IMAGE_LOCAL .
if [ $? != 0 ]; then
    echo "!!!Error: Build image failed."
    exit 1
fi
echo -e "\n##### $(docker images | grep -E "^$REPOSITORY\s+$TAG\s+")"

BUILD_COMPLETE=$(date +"%s")

#push image
if [[ $PUSH_IMAGE == "true" ]]; then
    ../../deployment/script/utils/push_image.sh $IMAGE_LOCAL
fi

FINISH=$(date +"%s")
echo
echo "##### Time elapsed ($(($FINISH - $START)) = $(($BUILD_COMPLETE - $START)) + $(($FINISH - $BUILD_COMPLETE)))"
exit 0
