#!/bin/bash

START=$(date +"%s")

#REPOSITORY & TAG & IMAGE
REPOSITORY="chainnova/ci/kubectl"
BASE_TAG="0.0.3"
TAG="0.0.4"
IMAGE_LOCAL="$REPOSITORY:$TAG"

echo
echo "##############################"
echo "##### build dependent images"
echo "##############################"
BASE_REPOSITORY="chainnova/ci/kubectl-base"
BASE_IMAGE_LOCAL="$BASE_REPOSITORY:$BASE_TAG"
docker images | grep -q -E "^$BASE_REPOSITORY\s+$BASE_TAG\s+"
if [ $? != 0 ]; then
    echo "Need to rebuild $BASE_IMAGE_LOCAL"
    docker build -f ./docker/Dockerfile_base -t $BASE_IMAGE_LOCAL .
    if [ $? != 0 ]; then
        echo "!!!Error: Build $BASE_IMAGE_LOCAL failed."
        exit 1
    fi
else
    echo "No need to rebuild $BASE_IMAGE_LOCAL"
fi

echo
echo "##############################"
echo "##### build image"
echo "##############################"
#build image
docker build --build-arg BASE_REPOSITORY=$BASE_REPOSITORY --build-arg BASE_TAG=$BASE_TAG -f ./docker/Dockerfile -t $IMAGE_LOCAL .
if [ $? != 0 ]; then
    echo "!!!Error: Build image failed."
    exit 1
fi
docker rmi $(docker images -q -f dangling=true)
echo -e "\n##### $(docker images | grep -E "^$REPOSITORY\s+$TAG\s+")"

BUILD_COMPLETE=$(date +"%s")

#push image
if [[ $PUSH_IMAGE == "true" ]]; then
    ../../script/utils/push_image.sh $IMAGE_LOCAL
fi

FINISH=$(date +"%s")
echo
echo "##### Time elapsed ($(($FINISH - $START)) = $(($BUILD_COMPLETE - $START)) + $(($FINISH - $BUILD_COMPLETE)))"
exit 0
