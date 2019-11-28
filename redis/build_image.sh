#!/bin/bash

START=$(date +"%s")

#REPOSITORY & TAG & IMAGE
REPOSITORY="chainnova/redis"
TAG="4.0.6"
IMAGE_LOCAL="$REPOSITORY:$TAG"
SCRIPT_DIR="../script/utils"

echo
echo "##############################"
echo "##### build image"
echo "##############################"
docker images | grep -q -E "^$REPOSITORY\s+$TAG\s+"
if [ $? == 0 ]; then
	docker rmi -f $IMAGE_LOCAL
	if [ $? != 0 ]; then
	    echo "!!!Error: Clean image $IMAGE_LOCAL error!"
	    exit 0
	fi
fi

#build image
docker build -f ./docker/Dockerfile -t $IMAGE_LOCAL ./docker
if [ $? != 0 ]; then
    echo "!!!Error: Build image failed."
    exit 1
fi
echo -e "\n##### $(docker images | grep -E "^$REPOSITORY\s+$TAG\s+")"

BUILD_COMPLETE=$(date +"%s")

#push image
if [[ $PUSH_IMAGE == "true" ]]; then
    cd $SCRIPT_DIR
    ./push_image.sh $IMAGE_LOCAL
    if [ $? != 0 ]; then
        echo "!!!Error: Push image failed."
        exit 1
    fi
    cd - &> /dev/null
fi

FINISH=$(date +"%s")
echo
echo "##### Time elapsed ($(($FINISH - $START)) = $(($BUILD_COMPLETE - $START)) + $(($FINISH - $BUILD_COMPLETE)))"
exit 0
